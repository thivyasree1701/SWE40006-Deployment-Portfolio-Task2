\# Task 2.3 – Launch Template and Auto Scaling Group



\## Objective



The objective of Task 2.3 was to extend the AWS WordPress deployment by implementing automatic instance management using:



\- EC2 Launch Template

\- Auto Scaling Group (ASG)

\- Application Load Balancer integration

\- Target Group integration

\- Scaling testing



\---



\# Step 1 – Create Launch Template



I opened:



```text

AWS Console

→ EC2

→ Instances

→ Launch Templates

→ Create launch template

```



I created:



```text

Launch Template Name: SWE40006-WordPress-LT

```



The Launch Template ID was:



```text

lt-0b40008e8b7db9198

```



Version:



```text

Version 1

```



The Launch Template contains the configuration required for the Auto Scaling Group to create EC2 instances.



\---



\# Step 2 – Configure Launch Template



The Launch Template was configured using the WordPress EC2 deployment configuration.



It included the required:



```text

Amazon Machine Image (AMI)

Instance type

Security configuration

Network configuration

WordPress server configuration

```



The purpose of the Launch Template is to provide a reusable EC2 configuration.



Instead of manually creating every EC2 instance, the Auto Scaling Group can use this template to automatically launch instances.



\---



\# Step 3 – Create Auto Scaling Group



I opened:



```text

EC2

→ Auto Scaling

→ Auto Scaling Groups

→ Create Auto Scaling group

```



The Auto Scaling Group was named:



```text

SWE40006-WordPress-ASG

```



The Launch Template selected was:



```text

SWE40006-WordPress-LT

```



\---



\# Step 4 – Configure Network



The Auto Scaling Group was configured in the same VPC as the WordPress deployment.



Multiple subnets/Availability Zones were available so that Auto Scaling could launch EC2 instances as required.



Using multiple Availability Zones also improves deployment availability compared with relying on only one zone.



\---



\# Step 5 – Connect ASG to Load Balancer



The Auto Scaling Group was integrated with the existing Application Load Balancer infrastructure.



The existing target group was selected:



```text

SWE40006-WordPress-TG

```



Therefore, EC2 instances created by the Auto Scaling Group could automatically participate in the load-balanced deployment.



Architecture:



```text

&#x20;                Internet

&#x20;                   |

&#x20;                   v

&#x20;         Application Load Balancer

&#x20;                   |

&#x20;                   v

&#x20;         SWE40006-WordPress-TG

&#x20;                   |

&#x20;          +--------+--------+

&#x20;          |                 |

&#x20;          v                 v

&#x20;     EC2 Instance      EC2 Instance

&#x20;          ^                 ^

&#x20;          |                 |

&#x20;          +--------+--------+

&#x20;                   |

&#x20;            Auto Scaling Group

&#x20;                   |

&#x20;                   v

&#x20;             Launch Template

```



\---



\# Step 6 – Configure Group Size



The initial Auto Scaling Group capacity was configured as:



```text

Minimum capacity: 1

Desired capacity: 1

Maximum capacity: 3

```



This means:



\- At least 1 instance should be maintained.

\- Normally 1 instance is required.

\- The group can scale up to a maximum of 3 instances.



\---



\# Step 7 – Verify Initial Instance



After the Auto Scaling Group was created, AWS automatically launched an EC2 instance using the Launch Template.



The Auto Scaling Group showed:



```text

Desired capacity: 1

Healthy instances: 1

```



This confirmed that the ASG could successfully create an EC2 instance.



\---



\# Step 8 – Test Scale Out



To demonstrate scaling, I manually changed:



```text

Desired capacity

1 → 2

```



AWS detected that the current number of instances was below the new desired capacity.



The Auto Scaling Group automatically launched another EC2 instance.



After the scaling operation, two ASG-managed EC2 instances were available.



\---



\# Step 9 – Verify Scale-Out Result



I checked:



```text

EC2

→ Auto Scaling Groups

→ SWE40006-WordPress-ASG

→ Instance management

```



The Auto Scaling Group showed the additional instance.



The scaling activity was also visible under:



```text

Activity

```



The Activity history recorded that an instance had been launched because the desired capacity changed from 1 to 2.



This provided evidence that scaling out was working.



\---



\# Step 10 – Test Scale In



After demonstrating scale out, I changed:



```text

Desired capacity

2 → 1

```



The Auto Scaling Group detected that there was one more EC2 instance than required.



AWS automatically selected and terminated an additional ASG instance.



\---



\# Step 11 – Verify Scale-In Result



The Auto Scaling Activity history showed the scale-in operation.



The activity demonstrated:



```text

Desired capacity changed from 2 to 1

```



followed by termination of an EC2 instance.



The group returned to:



```text

Desired capacity: 1

Minimum capacity: 1

Maximum capacity: 3

Healthy instances: 1

```



This confirmed that both scale-out and scale-in operations worked.



\---



\# Step 12 – Verify Target Group



The target group was checked after Auto Scaling.



The target group showed healthy registered targets during the scaling demonstration.



This confirmed integration between:



```text

Launch Template

&#x20;     |

&#x20;     v

Auto Scaling Group

&#x20;     |

&#x20;     v

EC2 Instances

&#x20;     |

&#x20;     v

Target Group

&#x20;     |

&#x20;     v

Application Load Balancer

```



\---



\# Step 13 – Final Scaling Test Result



The complete scaling test was:



```text

Initial:

Desired = 1

Instances = 1



&#x20;       |

&#x20;       | Scale Out

&#x20;       v



Desired = 2

Instances = 2



&#x20;       |

&#x20;       | Scale In

&#x20;       v



Desired = 1

Instances = 1

```



The AWS Auto Scaling Activity history provided evidence of both operations.



\---



\# Step 14 – Stop Resources After Testing



After completing the deployment and collecting the required evidence, I reduced the Auto Scaling Group capacity to prevent it from continuously creating EC2 instances.



The temporary post-assessment settings were:



```text

Desired capacity: 0

Minimum desired capacity: 0

Maximum desired capacity: 3

```



This shutdown configuration was performed only after the required scaling test had already been completed.



The Launch Template and Auto Scaling Group were retained as deployment evidence.



\---



\# Task 2.3 Result



Task 2.3 was successfully completed.



I demonstrated:



\- creation of an EC2 Launch Template

\- creation of an Auto Scaling Group

\- use of the Launch Template by the ASG

\- integration with the existing Target Group

\- integration with the Application Load Balancer

\- minimum, desired and maximum capacity configuration

\- automatic EC2 instance creation

\- manual scale-out test

\- scaling from 1 to 2 instances

\- manual scale-in test

\- scaling from 2 to 1 instance

\- automatic instance termination

\- Auto Scaling Activity history

\- healthy instance verification



\---



\# Evidence to Include



Screenshots for Task 2.3 should be stored in:



```text

screenshots/Task-2.3/

```



Important screenshots include:



1\. `SWE40006-WordPress-LT` Launch Template

2\. Launch Template version

3\. `SWE40006-WordPress-ASG`

4\. ASG capacity overview showing 1 / 1 / 3

5\. Target Group integration

6\. Instance management showing ASG instance

7\. Desired capacity changed from 1 to 2

8\. Two instances running after scale out

9\. Auto Scaling Activity showing instance launch

10\. Desired capacity changed from 2 to 1

11\. Auto Scaling Activity showing instance termination

12\. Final healthy ASG state



\---



\# Conclusion



The Auto Scaling Group successfully used the Launch Template to automatically manage EC2 instances.



The test demonstrated both:



```text

Scale Out: 1 → 2

Scale In:  2 → 1

```



Therefore, the AWS deployment demonstrated dynamic instance management using EC2 Auto Scaling.

