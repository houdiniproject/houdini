// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import CampaignGoalSelector, {CampaignGoalSelectorProps} from "../src/components/campaign_goal_selector/CampaignGoalSelector"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement, input:CampaignGoalSelectorProps) {
  ReactDOM.render(<Root><CampaignGoalSelector onChange={input.onChange} goal={input.goal} goalIsInSupporters={input.goalIsInSupporters} startingPoint={input.startingPoint}/></Root>, element)
}


(window as any).LoadCampaignGoalSelector = LoadReactPage