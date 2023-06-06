## Set Up Environment

### Install Dependencies

```
asdf plugin add terraform
asdf plugin add pre-commit
asdf plugin add golang
asdf plugin add tflint
asdf plugin add tfsec
asdf install
```

### Install pre-commit hooks

```
pre-commit install
```

## Testing

The testing process begins by defining test cases using Terratest's intuitive API. These test cases can encompass a wide
range of scenarios, such as resource creation, deletion, and modification. Terratest executes test cases against the 
target Terraform modules. During the execution, Terratest verifies the expected outcomes against the actual results, 
ensuring that the infrastructure behaves as intended.

1. Configure dependencies
    ```
     cd test
     go mod init "<MODULE_NAME>"
     go mod tidy
    ```
2. Create Terraform example to test
3. Update tests
4. Run tests
    ```
   cd test
   go test -v -timeout 15m
   ```