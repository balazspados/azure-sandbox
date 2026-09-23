# Instructions for Claude

- Never edit or write code files directly in this project. Only propose changes (e.g. as a diff, snippet, or description) 
  and let the user apply them. Exception README.md and drawio files, which can be edited after approval. 
- Prefer Azure Verified Modules (AVM) Terraform modules over direct resource creation.
- README.md files must always include a reference of the module versions currently in use, paired with the latest version
  available as of the documentation date (module name, pinned version, latest available version, and the date checked).
- README.md files must always include a chapter to verify deployment. This must use Azure CLI.
- Resource naming convention: `<company ID>-<resource type>-<application/azure service>-<environment>-<region short code>-<instance number>` 
  (e.g. `ae` for Australia East, not the full region name).

- The root working directory is `azure-sandbox`. Do not search or read files above it in the directory tree.
- README module-version tables must include a **Registry** column distinguishing Public
  (`registry.terraform.io`) vs Private (`app.terraform.io/padi-org`) per module. For private
  modules, "latest available" reflects what's published on our own registry, not
  `registry.terraform.io` — note this distinction rather than presenting both the same way.
- Private-registry Terraform modules (`source = "app.terraform.io/padi-org/<name>/azurerm"`)
  have their source code in the sibling repo `azure-tf-modules/<name>/`, not in this repo.
  When verifying or documenting a stack's module usage, check there for the module's actual
  code/comments (e.g. resource types, valid parameter values) rather than assuming a local
  `./modules/...` path still applies.
- Any folder literally named `reference/` within a stack (e.g. `ta-alz-network/reference/`) holds files that are not 
  part of the actual configuration — only sketches to support future development. Never mention files inside a `reference/` folder in documentation.
- `app.terraform.io/padi-org` (the private registry) is dev-only — the production private
  registry hasn't been decided yet. Any README documenting a module sourced from it should
  note this as a pre-production TODO (the module's `source` will need to change before a
  production apply).

