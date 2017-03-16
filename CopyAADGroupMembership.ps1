# Setup steps:
# > Set-ExecutionPolicy remotesigned
# > Install-Module -Name AzureADPreview

"This script takes a SOURCE group and a TARGET group."
"The TARGET group's membership is made to exactly match the SOURCE group's."
"The SOURCE group's membership is unchanged."

Try {
    # Connect with Credential Object
    $AzureAdCred = Get-Credential | out-null
    Connect-AzureAD -Credential $AzureAdCred
} Catch {
    # Print error and exit if sign-in failed
    echo $_.Exception.GetType().FullName, $_.Exception.Message
    break
}

# Ask for SOURCE and TARGET group display name
$SourceGroupName = Read-Host -Prompt "Input the SOURCE group display name"
$TargetGroupName = Read-Host -Prompt "Input the TARGET group display name"

# Counters used for the summary message when script is finished
$membersAdded = 0
$membersRemoved = 0

# Get groups and their members
$sourceGroup = Get-AzureADGroup -Filter "DisplayName eq '$SourceGroupName'"
$targetGroup = Get-AzureADGroup -Filter "DisplayName eq '$TargetGroupName'"
$sourceMembers = Get-AzureADGroupMember -ObjectId $sourceGroup.ObjectId
$targetMembers = Get-AzureADGroupMember -ObjectId $targetGroup.ObjectId

# Add all members from SOURCE to TARGET
foreach ($member in $sourceMembers) {
    If ($targetMembers -notcontains $member) {    
        Add-AzureADGroupMember -ObjectId $targetGroup.ObjectId -RefObjectId $member.ObjectId
        $membersAdded += 1
    }
}

# Remove all members from TARGET who are not in SOURCE
foreach ($member in $targetMembers) {
    If ($sourceMembers -notcontains $member) {
        Remove-AzureADGroupMember -ObjectId $targetGroup.ObjectId -MemberId $member.ObjectId
        $membersRemoved += 1
    }
}

""
"Operation completed."
"$membersAdded members added to TARGET group."
"$membersRemoved members removed from TARGET group."
