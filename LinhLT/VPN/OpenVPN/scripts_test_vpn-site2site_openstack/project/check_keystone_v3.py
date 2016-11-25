#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Keystone API monitoring script for Nagios
#
# Authors:
#   Duc Nguyen Cong (nguyencongduc3112@gmail.com)
#   Based on: https://github.com/rakesh-patnaik/nagios-openstack-monitoring#
# Requirments: python-keystoneclient, python-argparse, python
#
# How to use?
# python check_keystone_v3  --username admin --password Welcome123 --domain default --project admin --auth_url "http://172.16.69.130:35357/v3"''') 

import sys
import argparse
import requests

STATE_OK = 0
STATE_CRITICAL = 2

parser = argparse.ArgumentParser(description='''Check OpenStack Keystone API for availability.
Usage: python check_keystone_v3  --username admin --password Welcome123 --domain default --project admin --auth_url "http://172.16.69.130:35357/v3"''')

parser.add_argument('--auth_url', metavar='URL', type=str,
                    required=True,
                    help='Keystone URL')
parser.add_argument('--username', metavar='username', type=str,
                    required=True,
                    help='username to use for authentication')
parser.add_argument('--password', metavar='password', type=str,
                    required=True,
                    help='password to use for authentication')
parser.add_argument('--domain', metavar='domain', type=str,
                    required=True,
                    help='domain name to use for authentication')
parser.add_argument('--project', metavar='project', type=str,
                    required=True,
                    help='project name to use for authentication')
parser.add_argument('--insecure', action='store_false', dest='verify',
                    required=False,
                    help='Disable SSL verification.')
args = parser.parse_args()


headers = {'content-type': 'application/json'}

auth_token = None

try:

    #V2
    #auth_request = '{"auth":{"tenantName": "' + args.tenant + '", "passwordCredentials": {"username": "' +  args.username + '", "password": "' + args.password + '"}}}'

    auth_request = '{ "auth": { "identity": { "methods": [ "password" ], "password": { "user": { "name": "' + args.username + '", "domain": { "name": "' + args.domain + '" }, "password": "' + args.password + '" } } }, "scope": { "project": { "domain": { "name": "' + args.domain + '" }, "name": "' +args.project + '" } } } }'

    auth_response = requests.post(args.auth_url + '/auth/tokens', data=auth_request, headers=headers, verify=args.verify);


    if not auth_response.headers.get("X-Subject-Token"):
        raise Exception("Authentication failed. Failed to get an auth token.")

    auth_token = auth_response.headers.get("X-Subject-Token")

    if auth_token is None:
        print 'CRITICAL: Failed to generate an auth token for domain %s and user %s' % (args.domain, args.username) 
        sys.exit(STATE_CRITICAL)
    
except Exception as e:
    print 'CRITICAL: Athentication failed for domain %s and user %s: %s' % (args.domain, args.username, e) 
    sys.exit(STATE_CRITICAL)

#print 'OK: Successfully generated an auth token for domain %s and user %s' % (args.domain, args.username)
print auth_token
sys.exit(STATE_OK)
