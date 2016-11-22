#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#
# Authors:
#   Duc Nguyen Cong (nguyencongduc3112@gmail.com)
#   Based on: https://github.com/rakesh-patnaik/nagios-openstack-monitoring#
#
# How to use?
# python createproject.py --token $keystone_token --domain_id $domain_id --name_project $name_project --auth_url "http://172.16.69.53:5000/v3"

import sys
import argparse
import requests
import json

STATE_OK = 0
STATE_CRITICAL = 2

parser = argparse.ArgumentParser(description='Validate OpenStack Keystone token.')
parser.add_argument('--auth_url', metavar='URL', type=str,
                    required=True,
                    help='Keystone URL')
parser.add_argument('--token', metavar='TOKEN', type=str,
                    required=True,
                    help='The toke need to be validate')
parser.add_argument('--insecure', action='store_false', dest='verify',
                    required=False,
                    help='Disable SSL verification.')
parser.add_argument('--domain_id', metavar='DOMAINID', type=str,
                    required=True,
                    help='Domain ID')
parser.add_argument('--name_project', metavar='NAMEPROJECT', type=str,
                    required=True,
                    help='Name Project')
args = parser.parse_args()


headers = {'content-type': 'application/json', 'X-Auth-Token': args.token, 'X-Subject-Token': args.token}
payload = {
    "project": {
        "domain_id": args.domain_id,
        "enabled": True,
        "is_domain": False,
        "name": args.name_project
    }
}

try:
    auth_response = requests.post(args.auth_url + '/projects', headers=headers, verify=args.verify, data=json.dumps(payload));
    if auth_response.status_code == 201:
        sys.exit(STATE_OK)
    else:
        sys.exit(STATE_CRITICAL)

except Exception as e:
    sys.exit(STATE_CRITICAL)