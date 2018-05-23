// License: ISC
// from https://github.com/davidtheclark/react-aria-tabpanel
var createFocusGroup = require('focus-group');

/**
 * Exact same as normal TabManager but includes a callback for verifying we can actually change to a
 * new tab
 */
export class TabManager {
    options: any
    focusGroup: any
    tabs: any
    activeTabId: any
    tabPanels: any

    constructor(options: any) {
        this.options = options;

        var focusGroupOptions = {
            wrap: true,
            forwardArrows: ['down', 'right'],
            backArrows: ['up', 'left'],
            stringSearch: options.letterNavigation,
        };

        this.focusGroup = createFocusGroup(focusGroupOptions);

        // These component references are added when the relevant components mount
        this.tabs = [];
        this.tabPanels = [];

        this.activeTabId = options.activeTabId;
    }

    activate() {
        this.focusGroup.activate();
    };

    memberStartsActive(tabId: any) {
        if (this.activeTabId === tabId) {
            return true;
        }

        if (this.activeTabId === undefined) {
            this.activeTabId = tabId;
            return true;
        }

        return false;
    };

    registerTab(tabMember: any) {
        if (tabMember.index === undefined) {
            this.tabs.push(tabMember);
        } else {
            this.tabs.splice(tabMember.index, 0, tabMember);
        }

        var focusGroupMember = (tabMember.letterNavigationText) ? {
            node: tabMember.node,
            text: tabMember.letterNavigationText,
        } : tabMember.node;

        this.focusGroup.addMember(focusGroupMember, tabMember.index);

        this.activateTab(this.activeTabId || tabMember.id);
    };

    registerTabPanel(tabPanelMember: any) {
        this.tabPanels.push(tabPanelMember);
        this.activateTab(this.activeTabId);

        this.activateTab(this.activeTabId || tabPanelMember.tabId);
    };

    activateTab(nextActiveTabId: any) {
        if (this.options.canChangeTo) {
            if (!this.options.canChangeTo(nextActiveTabId)) {
                return;
            }

        }


        if (nextActiveTabId === this.activeTabId) return;
        this.activeTabId = nextActiveTabId;

        if (this.options.onChange) {
            this.options.onChange(nextActiveTabId);
            return;
        }

        this.tabPanels.forEach(function (tabPanelMember: any) {
            tabPanelMember.update(nextActiveTabId === tabPanelMember.tabId);
        });
        this.tabs.forEach(function (tabMember: any) {
            tabMember.update(nextActiveTabId === tabMember.id);
        });
    }

    handleTabFocus(focusedTabId: any) {
        this.activateTab(focusedTabId);
    };

    focusTab(tabId: any) {
        var tabMemberToFocus = this.tabs.find(function (tabMember: any) {
            return tabMember.id === tabId;
        });
        if (!tabMemberToFocus) return;
        tabMemberToFocus.node.focus();
    };

    destroy() {
        this.focusGroup.deactivate();
    };

    getTabPanelId(tabId: any) {
        return tabId + '-panel';
    }
}