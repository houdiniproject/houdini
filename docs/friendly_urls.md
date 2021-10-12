# Friendly URLs

Houdini has a concept called "Friendly URLs", that is an alternative for the
default Rails URLs to present the same navigation in a more user-friendly way.

The base for the URLs start with the nonprofit's state code, city and
nonprofit name in slug format.

> The slug is determined by: transforming the name in lower case; changing '@'
> for 'at'; changing '&' for 'and'; and replacing spaces and remaining special
> characters with hyphens. Read further on
> [Format::Url.convert_to_slug](https://github.com/houdiniproject/houdini/blob/main/lib/format/format/url.rb).
>
> More logic to the naming is applied when there is an entity with the same
> name. Read further on
> [SlugCopyNamingAlgorithm](https://github.com/houdiniproject/houdini/blob/main/lib/slug_copy_naming_algorithm.rb).

<!-- markdownlint-disable MD013 -->
| Path description | Default Rails URL | Friendly URL |
|:----------------:|:-----------------:|:------------:|
| Base URL (and main nonprofit page) | `/nonprofits/<nonprofit_id>` | `/<state_code>/<city>/<name>` |
| Dashboard   | `/nonprofits/<nonprofit_id>/dashboard` | `/<state_code>/<city>/<nonprofit_slug>/dashboard` |
| Donate frame     | `/nonprofits/<nonprofit_id>/donate` | `/<state_code>/<city>/<nonprofit_slug>/donate` |
| Button          | `/nonprofits/<nonprofit_id>/button` | `/<state_code>/<city>/<nonprofit_slug>/button` |
| Campaigns       | `/nonprofits/<nonprofit_id>/campaigns` | `/<state_code>/<city>/<nonprofit_slug>/campaigns` |
| An specific campaign | `/nonprofits/<nonprofit_id>/campaigns/<campaign_id>` | `/<state_code>/<city>/<nonprofit_slug>/campaigns/<campaign_slug>` |
| Supporters from an specific campaign | `/nonprofits/<nonprofit_id>/campaigns/<campaign_id>/supporters` | `/<state_code>/<city>/<nonprofit_slug>/campaigns/<campaign_slug>/supporters` |
| Events | `/nonprofits/<nonprofit_id>/events` | `/<state_code>/<city>/<nonprofit_slug>/events` |
| An specific event | `/nonprofits/<nonprofit_id>/events/<event_id>` | `/<state_code>/<city>/<nonprofit_slug>/events/<event_slug>` |
| Stats for an specific event | `/nonprofits/<nonprofit_id>/events/<event_id>/stats` | `/<state_code>/<city>/<nonprofit_slug>/events/<event_slug>/stats` |
| Tickets for an specific event | `/nonprofits/<nonprofit_id>/events/<event_id>/tickets` | `/<state_code>/<city>/<nonprofit_slug>/events/<event_slug>/tickets` |
