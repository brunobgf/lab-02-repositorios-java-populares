import requests
import pandas as pd
from datetime import datetime
import os
import dotenv
import json
import os
from git import Repo
from pygount import SourceAnalysis


def run_query(query, headers):
    request = requests.post('https://api.github.com/graphql', json={'query': query}, headers=headers)
    if request.status_code == 200:
        return request.json()
    else:
        raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, request.text))
    

def calculate_age(date_of_birth):
    current_date = datetime.utcnow()

    date_of_birth = datetime.strptime(date_of_birth, '%Y-%m-%dT%H:%M:%SZ')

    difference = current_date - date_of_birth

    age = difference.days // 365

    return age


def clone_repository(git_url):
  path_cloned_repositories = './cloned_repositories'

  if not os.path.exists(path_cloned_repositories):
    os.mkdir(path_cloned_repositories)

  repo_name = git_url.split('/')[-1].split('.')[0]
  os.mkdir(fr'{path_cloned_repositories}/{repo_name}')

  Repo.clone_from(git_url, fr'{path_cloned_repositories}/{repo_name}')


index = 1
data = []
end_cursor = "null"
num_repos = 1000
while len(data) < num_repos:
  query = '''{
    search (
        query: "stars:>20000, language:java"
        type: REPOSITORY
        first: 20
        after: ''' + end_cursor + '''
      ) {
        pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        node {
          ... on Repository {
            nameWithOwner
            stargazerCount
            url
            languages(first: 1) {
              edges {
                node {
                  name
                }
              }
            }
            primaryLanguage {
              name
            }
            createdAt
            releases(first: 100) {
              totalCount
              nodes {
                createdAt
              }
            }
          }
        }
      }
    }
  }
  '''
  dotenv.load_dotenv()
  headers = {"Authorization": f"Bearer {os.environ['API_TOKEN']}"}

  # print(json.dumps(run_query(query, headers), indent=3))
  # input()

  result = run_query(query, headers)["data"]["search"]
  end_cursor = "\"" + result["pageInfo"]["endCursor"] + "\"" if result["pageInfo"]["endCursor"] is not None else "null"
  repositories = []
  repositories.extend(list(map(lambda x: x['node'], result['edges'])))

  for repo in repositories:
      total_releases = None
      if repo['releases']['totalCount'] > 0:
          total_releases = repo['releases']['totalCount']

      data.append({
          'name': repo['nameWithOwner'].split('/')[1],
          'owner': repo['nameWithOwner'].split('/')[0],
          'url': repo['url'],
          'stars': repo['stargazerCount'],
          'age': calculate_age(repo['createdAt']),
          'primary_language': repo['primaryLanguage'],
          'total_releases': total_releases,
          'index': index
      })
      index += 1

print(json.dumps(data, indent=1))

df = pd.DataFrame(data=data)

if not os.path.exists('./output_csv_repos'):
  os.mkdir('./output_csv_repos')

df.to_csv('./output_csv_repos/repos.csv', index=False)

print('Finished')
