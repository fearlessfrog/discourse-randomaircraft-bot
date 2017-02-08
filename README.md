# Discourse Random Aircraft Quiz bot

Gets a random aircraft image from wikipedia and builds a post


## Usage

Type [randomaircraft] into a new post

## Installation

 * Add the plugin's repo url to your container's app.yml file

```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/fearlessfrog/discourse-randomaircraft.git
```

 * Rebuild the container

```
cd /var/docker
git pull
./launcher rebuild app
```

## Disclaimer

**THIS IS A WORK IN PROGRESS**

