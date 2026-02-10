### 1. Environment Variables (`env`)

```hcl
env = [
  "USERNAME=${var.username}",
  "PSWD=${var.password}"
]

```

In Docker Compose, you used `${USERNAME}`. In Terraform, we use **string interpolation**:

* **`var.username`**: References the variable defined in your `variables.tf`.
* **Interpolation `${}**`: Terraform evaluates the variable and injects it into the string.
* **Security**: Because `var.password` is marked as `sensitive = true` in your variables file, Terraform will ensure that while the container gets the password, the value isn't printed in plain text to your console or logs when you run `terraform apply`.

---

### 2. The Dynamic Volume Block (`dynamic "volumes"`)

This is the "pro" way to handle the **YAML Anchors** you had in your Compose file. Instead of writing 9 separate `volumes {}` blocks, we use a loop.

#### How it works:

1. **`for_each`**: This takes a **Map** (a collection of `Key = Value` pairs).
* **The Key**: The path inside the container (e.g., `"/var/log"`).
* **The Value**: The name of the Docker volume created by Terraform (e.g., `docker_volume.vols["user_log"].name`).


2. **`content`**: This is the template that runs for every item in your map.
3. **`volumes.key` and `volumes.value**`:
* `volumes` is the name of the iterator (it matches the label of the dynamic block).
* For the first loop, `key` is `"/home/shared"` and `value` is the actual name of your volume.



#### Why is this better than YAML Anchors?

* **Centralized Mapping**: If you need to change a mount point, you change it in one list.
* **Variable Injection**: Notice `"/home/${var.username}"`. You can't easily do complex string manipulation inside a YAML anchor, but here it's native.
* **Resource Dependency**: By referencing `docker_volume.vols[...]`, Terraform is smart enough to know it **must create the volumes first** before it tries to start the container.

---

### Comparison Table

| Feature | Docker Compose (YAML) | Terraform (HCL) |
| --- | --- | --- |
| **Reuse Logic** | YAML Anchors (`&` and `*`) | `dynamic` blocks + `for_each` |
| **Logic** | Static (Hard to manipulate) | Programmatic (Supports functions/loops) |
| **Dependencies** | Implicit (Docker handles order) | Explicit (Terraform builds a dependency graph) |
| **Validation** | Fails at runtime | Fails during `plan` (before deployment) |

---

### One Small Detail: `user_cache`

In your map, you are mounting the same volume (`user_cache`) to **two different locations**:

1. `/var/cache`
2. `/home/${var.username}/.cache`

This is perfectly valid in Docker! Both paths in the container will point to the exact same storage space on your disk.