from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.management import ParameterStore
from diagrams.aws.network import ELB, ClientVpn, VPC, NATGateway, InternetGateway, Route53

with Diagram("GoCD Infrastructure Diagram", show=False):
    vpn = ClientVpn("AWS VPN")

    with Cluster("VPC"):

        ssm = ParameterStore("SSM")
        r53 = Route53("DNS")

        with Cluster("Private Subnet"):
            igw = InternetGateway("Internet Gateway")
            gocd_server = EC2("GoCD Server")
            gocd_db_volume = RDS("GoCD DB Cluster")
            gocd_db_instance = EC2("GoCD DB Instance")

            with Cluster("Agents"):
                gocd_agents = [EC2("GoCD Agent 0"), EC2("GoCD Agent 1"), EC2("GoCD Agent 2")]

        with Cluster("Public Subnet"):
            ngw = NATGateway("NAT Gateway")

    vpn >> igw
    igw >> gocd_server
    gocd_server >> gocd_agents
    gocd_server >> gocd_db_volume >> gocd_db_instance
    gocd_agents >> ngw
    gocd_server >> r53