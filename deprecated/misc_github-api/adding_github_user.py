'''
Created on Dec 8, 2016

Currently only add LDAP user to the nceas-github group
run as: > python adding_github_user.py group user

@author: brun@nceas.ucsb.edu
'''
# adapted from http://stackoverflow.com/questions/36833231/adding-group-using-python-ldap


import sys
import ldap
import ldap.modlist as modlist
import getpass
import csv

my_groupname = "nceas-github"
my_username =  "brun"

class add_github_user:
    def __init__(self,ldap_server="ldaps://ldap.ecoinformatics.org/:636",mgr_dc="cn=Manager,dc=ecoinformatics,dc=org"):
        '''initialize the connection'''
        #adapted from http://www.tutorialized.com/tutorial/Create,-Read,-Update-and-Delete-with-Python-LDAP/39729

        # Open a connection
        self.ldapconn = ldap.initialize(ldap_server)
        # Get the password
        password = getpass.getpass("Please enter the ldap admin password:")
        #Bind/authenticate with a user with appropriate rights to add objects
        try:
            self.ldapconn.simple_bind_s(mgr_dc,password)
            print("Connection established")
        except:
            print("Connection failed, please check your password")


    def adding_ldapuser_group(self,group_name, user_name):
        '''Add LDAP user to the github group (cn)'''
        #Getting the current group status
        self.dn="cn=%s,ou=Account,dc=ecoinformatics,dc=org" % group_name
        current_group = self.ldapconn.search_s(self.dn,ldap.SCOPE_BASE)[0][1]
        # Creating the old and new group members list
        old_group_members={}
        old_group_members['uniqueMember'] = current_group['uniqueMember'][:]
        #write the previous group members list to a csv
        csv_filename = 'old_group_%s.csv' % group_name
        with open(csv_filename,'w') as f:
            w = csv.writer(f)
            w.writerows(old_group_members.items())
        #Add the new member to the member list
        new_group_members={}
        new_group_members['uniqueMember'] = old_group_members['uniqueMember'][:]
        new_group_members['uniqueMember'].append(str.encode('uid=%s,ou=Account,dc=ecoinformatics,dc=org'  % user_name)) 

        # Convert our dict to nice syntax for the add-function using modlist-module
        ldif = modlist.modifyModlist(old_group_members,new_group_members)
        # Do the actual synchronous add-operation to the ldapserver
        try:
            self.ldapconn.modify_s(self.dn,ldif)
            print("User added succesfully")
        except:
            print("A problem occured, the user was not added.")
            print("Please check that this username exists")

    def end_ldap_conn(self):
        '''Close the connection'''
        self.ldapconn.unbind_s()
        print("Connection closed")


if __name__ == '__main__':
    my_groupname = sys.argv[1]
    my_username =  sys.argv[2]
    print("Adding user %s to group %s" %(my_username,my_groupname))
    

    # Create the instance
    my_adder = add_github_user()
    # Add the user
    my_adder.adding_ldapuser_group(my_groupname, my_username)
    # Close the connection
    my_adder.end_ldap_conn()
