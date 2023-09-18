# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Get a specific domain user's details - replace 'p' with a specific user identity or parameterize it.
$user = Get-ADUser -Identity 'p'
if (-not $user) {
    Write-Error "Unable to find user with identity 'p'"
    return
}

# Get the ACL for the user object
$objectDN = $user.DistinguishedName
$aclObject = Get-Acl -Path "AD:\$objectDN"
if (-not $aclObject) {
    Write-Error "Unable to retrieve ACL for $objectDN"
    return
}

# Print the access rules
foreach ($rule in $aclObject.Access) {
    Write-Host "IdentityReference: $($rule.IdentityReference)"
    Write-Host "AccessControlType: $($rule.AccessControlType)"
    Write-Host "Rights: $($rule.ActiveDirectoryRights)"
    Write-Host "InheritanceType: $($rule.InheritanceType)"
    Write-Host "ObjectType: $($rule.ObjectType)"
    Write-Host "--------------------------------------------"
}
