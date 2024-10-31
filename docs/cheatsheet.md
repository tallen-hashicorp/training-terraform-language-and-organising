# **Terraform Cheat Sheet**

## **Basic Commands**
- **Initialize**: `terraform init`
- **Validate Syntax**: `terraform validate`
- **Show Execution Plan**: `terraform plan`
- **Apply Changes**: `terraform apply`
- **Destroy Resources**: `terraform destroy`
- **Format Code**: `terraform fmt`
- **State Management**: 
  - List resources: `terraform state list`
  - Show resource details: `terraform state show <resource>`

---

## **File Structure**
- **`main.tf`** - Core configurations
- **`variables.tf`** - Define input variables
- **`outputs.tf`** - Define outputs
- **`terraform.tfvars`** - Provide variable values
- **`.tfstate`** - Stores resource state

---

## **Core Blocks**

### **`provider` Block**
Define cloud provider settings.
```hcl
provider "aws" {
  region = "us-west-2"
}
```

### **`resource` Block**
Define resources to create.
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}
```

### **`variable` Block**
Define input variables.
```hcl
variable "region" {
  type    = string
  default = "us-west-2"
}
```

### **`output` Block**
Display values after applying.
```hcl
output "instance_id" {
  value = aws_instance.example.id
}
```

### **`module` Block**
Reuse code from a module.
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}
```

### **`data` Block**
Fetch data (e.g., existing resources).
```hcl
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

### **`locals` Block**
Define reusable values within a config.
```hcl
locals {
  instance_type = "t2.micro"
}
```

---

## **Syntax and Tips**

### **Comments**
```hcl
# Single-line comment
/* Multi-line 
   comment */
```

### **Interpolation**
Use `${}` to insert dynamic values.
```hcl
resource "aws_instance" "example" {
  tags = {
    Name = "instance-${var.environment}"
  }
}
```

### **Dependencies**
- **Implicit**: Automatically inferred by Terraform.
- **Explicit**: Use `depends_on` if needed.
```hcl
resource "aws_instance" "example" {
  depends_on = [aws_vpc.example_vpc]
}
```

### **Variable Types**
```hcl
variable "allowed_ips" {
  type = list(string)
}
```

### **Conditionals**
```hcl
count = var.create_instance ? 1 : 0
```

---

## **Common Patterns**

### **Setting Variables**
1. **Environment variable**: `export TF_VAR_region="us-east-1"`
2. **File-based**: `terraform.tfvars`:
   ```hcl
   region = "us-east-1"
   ```

### **Outputs with Sensitive Data**
Mark outputs as sensitive if they contain secrets.
```hcl
output "db_password" {
  value     = aws_db_instance.db.password
  sensitive = true
}
```