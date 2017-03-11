# > Set-ExecutionPolicy remotesigned
# > Install-Module -Name AzureADPreview

# Azure AD v2 PowerShell Quickstart Connect

"This script takes a SOURCE group and a TARGET group."
"The TARGET group's membership is made to exactly match the SOURCE group's."
"The SOURCE group's membership is unchanged."
$SourceGroupName = Read-Host -Prompt "Input the SOURCE group name"
$TargetGroupName = Read-Host -Prompt "Input the TARGET group name"

$membersAdded = 0
$membersRemoved = 0

# Connect with Credential Object
#$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred | out-null

# Get groups and their members
$sourceGroup = Get-AzureADGroup -Filter "DisplayName eq '$SourceGroupName'"
$targetGroup = Get-AzureADGroup -Filter "DisplayName eq '$TargetGroupName'"
$source_members = Get-AzureADGroupMember -ObjectId $sourceGroup.ObjectId
$target_members = Get-AzureADGroupMember -ObjectId $targetGroup.ObjectId

# Add all members from SOURCE to TARGET
foreach ($member in $source_members) {
    If ($target_members -notcontains $member) {    
        Add-AzureADGroupMember -ObjectId $targetGroup.ObjectId -RefObjectId $member.ObjectId
        $membersAdded += 1
    }
}

# Remove all members from TARGET who are not in SOURCE
foreach ($member in $target_members) {
    If ($source_members -notcontains $member) {
        Remove-AzureADGroupMember -ObjectId $targetGroup.ObjectId -MemberId $member.ObjectId
        $membersRemoved += 1
    }
}

""
"SUCCESS: Operation completed."
"$membersAdded members added to TARGET group."
"$membersRemoved members removed from TARGET group."
