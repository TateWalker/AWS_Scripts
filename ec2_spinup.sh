declare -A AMIS
AMIS[amazon]=ami-056ee704806822732
AMIS[redhat]=ami-00fc224d9834053d6
AMIS[ubuntu]=ami-068670db424b01e9a
AMIS[cuda]=ami-0f4ae762b012dbf78

declare -A LOGINS
LOGINS[amazon]=ec2-user
LOGINS[redhat]=ec2-user
LOGINS[ubuntu]=ubuntu
LOGINS[cuda]=ubuntu


sizes=("t2.nano" "t2.micro" "t2.small" "t2.medium" "t2.large" "t2.xlarge" "t2.2xlarge" "t3a.nano" "t3a.micro" "t3a.small" "t3a.medium" "t3a.large" "t3a.xlarge" "t3a.2xlarge" "t3.nano" "t3.micro" "t3.small" "t3.medium" "t3.large" "t3.xlarge" "t3.2xlarge" "m5a.large" "m5a.xlarge" "m5a.2xlarge" "m5a.4xlarge" "m5a.8xlarge" "m5a.12xlarge" "m5a.16xlarge" "m5a.24xlarge" "m5d.large" "m5d.xlarge" "m5d.2xlarge" "m5d.4xlarge" "m5d.8xlarge" "m5d.12xlarge" "m5d.16xlarge" "m5d.24xlarge" "m5d.metal" "m5.large" "m5.xlarge" "m5.2xlarge" "m5.4xlarge" "m5.8xlarge" "m5.12xlarge" "m5.16xlarge" "m5.24xlarge" "m5.metal" "m4.large" "m4.xlarge" "m4.2xlarge" "m4.4xlarge" "m4.10xlarge" "m4.16xlarge" "c5d.large" "c5d.xlarge" "c5d.2xlarge" "c5d.4xlarge" "c5d.9xlarge" "c5d.18xlarge" "c5.large" "c5.xlarge" "c5.2xlarge" "c5.4xlarge" "c5.9xlarge" "c5.18xlarge" "c4.large" "c4.xlarge" "c4.2xlarge" "c4.4xlarge" "c4.8xlarge" "g2.2xlarge" "g2.8xlarge" "g3.4xlarge" "g3.8xlarge" "g3.16xlarge" "r5a.large" "r5a.xlarge" "r5a.2xlarge" "r5a.4xlarge" "r5a.8xlarge" "r5a.12xlarge" "r5a.16xlarge" "r5a.24xlarge" "r5d.large" "r5d.xlarge" "r5d.2xlarge" "r5d.4xlarge" "r5d.8xlarge" "r5d.12xlarge" "r5d.16xlarge" "r5d.24xlarge" "0r5d.metal" "r5.large" "r5.xlarge" "r5.2xlarge" "r5.4xlarge" "r5.8xlarge" "r5.12xlarge" "r5.16xlarge" "r5.24xlarge" "r5.metal" "r4.large" "r4.xlarge" "r4.2xlarge" "r4.4xlarge" "r4.8xlarge" "r4.16xlarge" "z1d.large" "z1d.xlarge" "z1d.2xlarge" "z1d.3xlarge" "z1d.6xlarge" "z1d.12xlarge" "z1d.metal" "d2.xlarge" "d2.2xlarge" "d2.4xlarge" "d2.8xlarge" "i2.xlarge" "i2.2xlarge" "i2.4xlarge" "i2.8xlarge" "i3.large" "i3.xlarge" "i3.2xlarge" "i3.4xlarge" "i3.8xlarge" "i3.16xlarge" "i3.metal" "i3en.large" "i3en.xlarge" "i3en.2xlarge" "i3en.3xlarge" "i3en.6xlarge" "i3en.12xlarge" "i3en.24xlarge")

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

if [ "$#" -ne 3 ]; then
    echo "Usage: [Image Type] [Size] [Name]";
    exit;
fi

if ! [[ -v AMIS[$1] ]]; then echo Pick a valid AMI: amazon, redhat, ubuntu, cuda; exit; fi
if ! containsElement "$2" "${sizes[@]}" ; then echo Pick a valid size: ${sizes[@]}; exit; fi




pip install awscli --upgrade --user > /dev/null 2>&1
if [ ! -f ~/.aws/config ]; then
    echo -e "PUBLIC SECURITY CRED HERE\nSECRET SECURITY CRED HERE\nREGION HERE\njson\n" | aws configure > /dev/null 2>&1;
    echo "Config file doesn't exist. Set credentials to default. Overwrite with 'aws configure'"
fi
aws ec2 run-instances --image-id ${AMIS[$1]} --count 1 --instance-type $2 --key-name PEM FILE NAME --security-group-ids SECURITY GROUP ID HERE  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=""${3}""}]"  > /dev/null 2>&1
instance=$(aws ec2 describe-instances  --query 'sort_by(Reservations[].Instances[], &LaunchTime)[:].[InstanceId,PublicIpAddress,LaunchTime]'[-1][0] | python3 -c "import sys, json; print(json.load(sys.stdin))")
pub_dns=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[0].Instances[0].PublicDnsName' | python3 -c "import sys, json; print(json.load(sys.stdin))")
sleep 5
ssh -i "YOUR PEM FILE HERE" ${LOGINS[$1]}@$pub_dns
