# Terraform Module for Metabase

Metabase is an open-source business intelligence (BI) tool that enables users to analyze and visualize data from various data sources. It provides a user-friendly interface that allows non-technical users to explore and make sense of data without requiring advanced programming or SQL skills.

The metabase terraform module is a preconfigured collection of files and resources designed for configuring metabase using terraform. With this module, you can easily handle various metabase configurations, including user groups, data source settings, and permission mappings. This module abstracts away the complexity of configuring metabase, providing a simplified and streamlined process.

```text
It's important to understand that the module data is not treated as sensitive by default. In order to conceal both the data submitted by this provider and the data received from the API, you will need to configure the environment variable API_DATA_IS_SENSITIVE=true.
```



## Module Providers

| Name              | Version|
|-------------------|--------|
| Mastercard/restapi| 1.18.0 |
| hashicorp/http    | n/a    |



## Module Inputs

| Name                          | Description                                             | Type           | Default | Required |
| ----------------------------- | ------------------------------------------------------- | -------------- | ------- | :------: |
| metabase\_session\_token      | The metabase X-Metabase-Session token                   | `string`       | n/a     |   yes    |
| create\_metabase\_user\_group | Create metabase user group                              | `bool`         | true    |   yes    |
| metabase\_user\_group_name    | The metabase user group name                            | `string`       | n/a     |   yes    |
| metabase\_user\_group_id      | A user group ID that already exists within the metabase | `number`       | 1       |   yes    |
| database\_engine              | The database engine (mysql, postgres)                   | `string`       | n/a     |   yes    |
| database\_host                | The database hostname                                   | `string`       | n/a     |   yes    |
| database\_port                | The database port                                       | `number`       | n/a     |   yes    |
| database\_username            | The database username                                   | `string`       | n/a     |   yes    |
| database\_password            | The database password                                   | `string`       | n/a     |   yes    |
| database\_connection\_info    | Database connection information                         | `list(object)` | n/a     |   yes    |
| ssl\_enabled                  | Enable SSL for database connections                     | `bool`         | false   |   yes    |
| ssh\_tunnel\_enabled          | Enable SSH tunneling for database connections           | `bool`         | false   |   yes    |
| advanced\_options\_enabled    | Enable metabase advanced options                        | `bool`         | false   |   yes    |



## Module Outputs

| Name            | Description                            |
|-----------------|----------------------------------------|
| database\_id    | The database id assigned by metabase   |
| user\_group\_id | The user group id assigned by metabase |



## Module Usage

### Prerequisites 

##### 1. Define the following provider configurations in calling module provider.tf

```terraform
data "http" "session_token" {
  url    = "${var.metabase_api_endpoint}/session"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    username = var.metabase_username
    password = var.metabase_password
  })
}

provider "restapi" {
  uri                   = var.metabase_api_endpoint
  create_returns_object = true
  write_returns_object  = true
  rate_limit            = 1
  timeout               = 120
  headers = {
    X-Metabase-Session = jsondecode(data.http.session_token.response_body).id
    Content-Type       = "application/json"
  }
}
```

##### 2. Define the following provider versions in calling module versions.tf

```terraform
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.18.0"
    }
  }
  required_version = ">= 1.0"
}
```

##### 3. Define the following variables in calling module variables.tf

```terraform
variable "metabase_api_endpoint" {
  type    = string
  default = "https://metabase.example.com/api"
}

variable "metabase_username" {
  type      = string
  sensitive = true
}

variable "metabase_password" {
  type      = string
  sensitive = true
}
```

### Module Example

```terraform
module "foo" {
  create_metabase_user_group = true
  metabase_user_group_name   = "foo"
  database_engine            = "mysql"
  database_host              = "db-foo.bar.local"
  database_port              = 3306
  database_username          = "foo"
  database_password          = "bar"
  database_connection_info   = [
    {
      display_name  = "foo-bar-a"
      database_name = "foo_bar_a"
    },
    {
      display_name  = "foo-bar-b"
      database_name = "foo_bar_b"
    },
    {
      display_name  = "foo-bar-c"
      database_name = "foo_bar_c"
    }
  ]
}
```

