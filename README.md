# Fastcampus-elasticsearch
이 저장소는 패스트캠퍼스의 Elasticsearch 강좌를 위한 것입니다. 이 강좌는 학생들이 Elasticsearch를 사용하여 검색 클러스터 및 검색 기능을 구현하는 방법을 배우도록 돕기 위해 설계되었습니다.

# NOTE
- Terraform 을 사용할 때는 반드시 main.tf 에서 입력해야 할 변수가 없는지 확인하세요. 특히, AWS 의 subnet ids 또는 vpc ids 는 계정마다 다르기 때문에 반드시 구성해줘야 합니다.
- DockerDesktop 을 통해서 Docker 를 실행할 때는 반드시 충분한 메모리를 사용할 수 있게 Docker Desktop 설정에서 충분한 메모리를 확보하세요.