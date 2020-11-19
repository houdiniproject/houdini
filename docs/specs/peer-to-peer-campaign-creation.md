# nonprofit/{nonprofit_id}/peer-to-peer Specification

Houdini users can create campaigns that they run on behalf of nonprofit and
where all of the money raised in the campaign is directed to the nonprofit
automatically. We call these peer-to-peer campaigns, or P2P campaigns for short
and the user creating the campaign is the "campaign creator". The expectation is
that a P2P campaign creator would notify their friends, colleagues and potential
donors about the campaign. Adding a personal touch can build trust and can
increase giving.

There are two different types of p2p campaigns, full p2p campaigns and child p2p
campaigns. While both provide an ability for an individual to raise money on
behalf of a nonprofit, there are key differences.

In a child p2p campaign, a p2p campaign is associated with a campaign that the
nonprofit had already created on its own. As an example, consider the situation
where a nonprofit is running an End of 2020 Fundraising Drive with a goal of
raising $20,000 by a given date. In the context of child p2p campaigns, this
original campaign would be called the "parent campaign". An individual would be
able to create their own fundraising campaign connected to the "parent
campaign", this campaign is called a "child campaign". All money raised by the
child campaign will be associated with the parent campaign and will go towards
any fundraising goal of the parent campaign. As an example, if a child campaign
associated with the End of 2020 Fundraising Drive described above raises $1000,
that $1000 will be associated with both the child campaign and the parent
campaign and will apply to the goals for both of them. Additionally, a child
campaign's page design is identical to the parent page's design. The only
difference significant difference is that the campaign includes the child
campaign creator's name, city, state and/or country as well as a reason for
supporting the campaign listed.

### Include pic of a p2p page

In a full campaign, a campaign creator has full control over the design of the
campaign and has all of the features normally available for a nonprofit user
creating a campaign. The only difference for the nonprofit user is the have
slightly less access to payment information related to the campaign contributors.

## Include pic of Full campaign page

## Components

There are a number of components needed on this page:

* PeerToPeerCreatePage
* LocationSelector
* ChildCampaignCreator
* FullCampaignCreator

## Characteristics of all components in specification

* MUST be written to use React hooks and be a React function component.
* MUST be keyboard accessible (implied by the next item but just to be clear)
* MUST be WCAG 2.1, level AA compatible or close. The best tool I've found for
finding these bugs is The AXE Beta tool. It
[requires registration](https://www.deque.com/axe/beta/) and installation
of the extension in Chrome/Chromium. Another good approximation for testing
this is going to the Firefox Development Tools, going to `Check for Issues`
and selecting `All Issues`. Other tools to assist are the
[non-beta Axe Browser Extension](https://www.deque.com/axe/browser-extensions/)
and [the Wave Browser Extension](https://wave.webaim.org/extension/). This is
admittedly a big task to be perfect so let's try our best.
* MUST use text from the current locale
* MUST use Material-UI components as much as possible.
* MUST use the current theme for styling.

## LocationSelector

LocationSelector is used for setting the Country, State and City for an input.

### Related types

```typescript
interface Location {
	country?:string
	city?:string
	stateCode?: string
}

```

### Properties

* initialLocation - a Location to prefill the fields (through Formik)
* enableReinitialize - boolean if true, changes to initialLocation update the
fields, otherwise, they're not updated
* onUpdate: a function passed in which takes the updated Location from
  LocationSelector (returns void)
