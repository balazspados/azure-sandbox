# Instructions for Claude

- Never edit or write code files directly in this project. Only propose changes (e.g. as a diff, snippet, or description) and let the user apply them. Exception README.md and drawio files, which can be edited after approval. 
- Prefer Azure Verified Modules (AVM) Terraform modules over direct resource creation.
- README.md files must always include a reference of the module versions currently in use, paired with the latest version available as of the documentation date (module name, pinned version, latest available version, and the date checked).
- README.md files must always include a chapter to verify deployment. This must use Azure CLI.
- Resource naming convention: `<company ID>-<resource type>-<application/azure service>-<environment>-<region>-<instance number>`
- The root working directory is `azure-sandbox`. Do not search or read files above it in the directory tree.

