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
    # Try to resolve the SID to a friendly name
    try {
        $resolvedIdentity = $rule.IdentityReference.Translate([System.Security.Principal.NTAccount])
    } catch {
        # If translation fails, use the original SID as the resolved identity
        $resolvedIdentity = $rule.IdentityReference.ToString()
    }

    Write-Host "IdentityReference (SID): $($rule.IdentityReference)"
    Write-Host "IdentityReference (Name): $resolvedIdentity"
    Write-Host "AccessControlType: $($rule.AccessControlType)"
    Write-Host "Rights: $($rule.ActiveDirectoryRights)"
    Write-Host "InheritanceType: $($rule.InheritanceType)"
    Write-Host "IsInherited: $($rule.IsInherited)"  # Indicates if the rule is inherited from a parent object
    Write-Host "InheritanceFlags: $($rule.InheritanceFlags)"  # Provides more granularity on inheritance type
    Write-Host "PropagationFlags: $($rule.PropagationFlags)"  # Specifies how inheritance is propagated
    Write-Host "ObjectType: $($rule.ObjectType)"
    Write-Host "--------------------------------------------"
}
