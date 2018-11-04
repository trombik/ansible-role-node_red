# Ansible role `node_red`

Install `node-red`. The role installs `node-red` using `npm`.

## Logging

`node-red` itself does not support granular logging outputs, but simple logging
to a file. The role configures `node-red` to log all console outputs to
`syslog`, which is not very pretty (duplicated time stamp).

# Requirements

* `nodejs` and `npm` (use [`trombik.nodejs`](https://github.com/trombik/ansible-role-nodejs))

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `node_red_user` | User of `node-red` | `node-red` |
| `node_red_group` | Group of `node-red` | `node-red` |
| `node_red_service` | Service name of `node-red` | `node_red` |
| `node_red_package` | `npm` package name of `node-red` | `node-red` |
| `node_red_db_dir` | Path to a directory where files are kept | `{{ __node_red_db_dir }}` |
| `node_red_conf_dir` | Path to base directory of `settings.js` | `{{ __node_red_conf_dir }}` |
| `node_red_conf_file` | Path to `settings.js` | `{{ node_red_conf_dir }}/settings.js` |
| `node_red_extra_packages` | A list of dict to install extra packages (see below) | `[]` |
| `node_red_extra_npm_packages` | A list of dict to install extra `npm` packages (see below) | `[]` |
| `node_red_bind_address` | Address and port that `node-red` listens on (used in play to ensure the daemon is running and ready) | `127.0.0.1:1880` |
| `node_red_config` | Content of `settings.js` | `""` |
| `node_red_flags` | (not implemented yet) | `""` |

## `node_red_extra_packages`

A list of dict to install extra packages.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | Name of the package | Yes |
| `state` | State of the package. The value should be one of supported `state` value of ansible package module, such as `present`. | No |

## `node_red_extra_npm_packages`

A list of dict to install extra `npm` packages.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | Name of the package | Yes |
| `state` | State of the package. The value should be one of supported `state` value of ansible `npm` module, such as `present`. | No |

## Debian

| Variable | Default |
|----------|---------|
| `__node_red_db_dir` | `/var/lib/node-red` |
| `__node_red_conf_dir` | `/etc/node-red` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__node_red_db_dir` | `/var/db/node-red` |
| `__node_red_conf_dir` | `/usr/local/etc/node-red` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - name: trombik.apt_repo
      when: ansible_os_family == 'Debian'
    - name: trombik.nodejs
    - ansible-role-node_red
  vars:
    apt_repo_keys_to_add:
      - https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    apt_repo_enable_apt_transport_https: yes
    apt_repo_to_add:
      - "deb https://deb.nodesource.com/node_8.x {{ ansible_distribution_release }} main"
    nodejs_npm_package: "{% if ansible_os_family == 'Debian' %}nodejs{% else %}npm{% endif %}"
    node_red_extra_packages:
      - name: zsh
        state: present
    node_red_extra_npm_packages:
      - name: node-red-contrib-influxdb
        state: present
    node_red_config: |
      module.exports = {
        uiPort: {{ node_red_bind_address.split(':')[1] }},
        mqttReconnectTime: 15000,
        serialReconnectTime: 15000,
        debugMaxLength: 1000,
        functionGlobalContext: {},
        logging: {
          console: {
            level: "info",
            metrics: false,
            audit: false
          }
        },
        editorTheme: {
          projects: {
            enabled: false
          }
        },
      }
```

# License

```
Copyright (c) 2018 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
