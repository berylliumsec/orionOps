import argparse
import logging
from ldap3 import Server, Connection, ALL

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def enumerate_dacl(host, user_dn, username, password, port=389, use_ssl=False):
    """
    Enumerate DACL for a user in an Active Directory environment.

    Parameters:
    - host: LDAP server address.
    - user_dn: Distinguished Name of the user for which DACL should be enumerated.
    - username: Bind username for LDAP connection.
    - password: Bind password for LDAP connection.
    - port: LDAP port (default is 389).
    - use_ssl: Use SSL for LDAP connection (default is False).
    """

    server = Server(host, port=port, use_ssl=use_ssl, get_info=ALL)
    conn = Connection(server, username, password, auto_bind=True)

    # Fetch nTSecurityDescriptor
    success = conn.search(user_dn, '(objectClass=*)', attributes=['nTSecurityDescriptor'])
    if not success:
        logger.error("Failed to fetch nTSecurityDescriptor for %s", user_dn)
        return

    # Check if the attribute exists in the retrieved entry
    if 'nTSecurityDescriptor' in conn.entries[0]:
        dacl = conn.entries[0]['nTSecurityDescriptor'].value.dacl
        for ace in dacl:
            print(f"ACE Type: {ace['type']}")
            print(f"Principal: {ace['trustee']['identifier']}")
            print(f"Access Mask: {ace['access_mask']}")
            print("------")
    else:
        logger.error("'nTSecurityDescriptor' attribute not found for %s", user_dn)

    dacl = conn.entries[0]['nTSecurityDescriptor'].value.dacl
    for ace in dacl:
        print(f"ACE Type: {ace['type']}")
        print(f"Principal: {ace['trustee']['identifier']}")
        print(f"Access Mask: {ace['access_mask']}")
        print("------")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Enumerate DACL for a user in AD from a Linux machine.")
    parser.add_argument("host", help="LDAP server address")
    parser.add_argument("user_dn", help="Distinguished Name of the user for which DACL should be enumerated")
    parser.add_argument("username", help="Bind username for LDAP connection")
    parser.add_argument("password", help="Bind password for LDAP connection")
    parser.add_argument("--port", type=int, default=389, help="LDAP port (default is 389)")
    parser.add_argument("--use-ssl", action="store_true", help="Use SSL for LDAP connection")

    args = parser.parse_args()

    try:
        enumerate_dacl(args.host, args.user_dn, args.username, args.password, args.port, args.use_ssl)
    except Exception as e:
        logger.error("Error enumerating DACL: %s", str(e))
