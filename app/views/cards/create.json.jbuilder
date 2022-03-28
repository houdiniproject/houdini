# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.(@source_token, :token)

json.holder_id @source_token.tokenizable.holder_id
json.holder_type @source_token.tokenizable.holder_type
