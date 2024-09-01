#!/bin/bash

vagrant up --no-provision

ping ca.domain -c 1
ping ldap.domain -c 1
ping harbor.domain -c 1

vagrant provision
