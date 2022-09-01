// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {action, computed, observable} from 'mobx'
import {AbstractTabComponentState, AbstractTabPanelState} from "./abstract_tabcomponent_state";
import {mount, ReactWrapper} from 'enzyme';
import {Wrapper} from "./Wrapper";
import {TabList} from "./TabList";
import {TabPanel} from "./TabPanel";
import {Tab} from "./Tab";
import toJson from 'enzyme-to-json';
import {UniqueIdMock} from "../../test/unique_id_mock";
import {mountForMobx, runTestsOnConditions, TriggerAndAction} from '../../test/react_test_helpers';

let uniqueIdMock = new UniqueIdMock();

// function isVisible(wrapper: ReactWrapper) {
//   const style: any = wrapper.prop("style");
//   if (style) {
//     const display = style['display'];
//     if (display)
//       return display !== 'none'
//   }
//   return true
//
//
// }

// function isEnabledTab(tabWrapper: NonNullable<ReactWrapper>, tabPanelWrapper: NonNullable<ReactWrapper>) {
//   expect(tabWrapper).toBeTruthy();
//   expect(tabPanelWrapper).toBeTruthy();
//   expect(tabWrapper.hostNodes().prop('className')).toBe('enabled');
//   expect(isVisible(tabPanelWrapper.hostNodes())).toBeTruthy()
// }

// function isDisabledTab(tabWrapper: NonNullable<ReactWrapper>, tabPanelWrapper: NonNullable<ReactWrapper>) {
//   expect(tabWrapper).toBeTruthy();
//   expect(tabPanelWrapper).toBeTruthy();
//   expect(tabWrapper.prop('className')).toBeUndefined();
//   expect(isVisible(tabPanelWrapper)).toBeFalsy()
// }

class MockableTabPanelState extends AbstractTabPanelState {
  @observable
  isEnabled: boolean;

  @action.bound
  setEnabled(enabled: boolean) {
    this.isEnabled = enabled;
  }

  @computed
  get enabled(): boolean {
    return this.isEnabled
  }

}


class EasyTabComponentState extends AbstractTabComponentState<MockableTabPanelState> {
  constructor() {
    super(MockableTabPanelState)
  }

  wrapperForFocus: ReactWrapper;

  @action.bound
  addTab(tab: { tabName: string, label: string }): MockableTabPanelState {
    const newTab = super.addTab(tab);
    if (this.panels.length == 1) {

      newTab.setEnabled(true);
      this.activateTab(newTab)
    }
    return newTab
  }

  uniqueIdFunction(prefix?:string) {
    return uniqueIdMock.uniqueId.bind(uniqueIdMock)(prefix);
  }

  focusFunction(panel:MockableTabPanelState){
    this.wrapperForFocus.find(`#${panel.id}`).hostNodes().prop('onFocus')(null)
  }

}

describe('Wrapper', () => {

  let data =
    {
      tab1: {
        tabName: "Tab1",
        label: "Label1"
      },
      tab2: {
        tabName: "Tab2",
        label: "Label2"
      },
      tab3: {
        tabName: "Tab3",
        label: "Label3"
      },


    };

  beforeEach(() => {
    uniqueIdMock.reset()
  });

  it('.createTab', () => {
    let state = new EasyTabComponentState();


    state.addTab({tabName: data.tab1.tabName, label: data.tab1.label});
    let tab = state.tabsByName[data.tab1.tabName];

    let wrapper = mount(<Wrapper manager={state}>
      <TabList>
        <Tab id={tab.id} key={tab.id} className={tab.enabled ? 'enabled' : undefined}
             active={tab.active}>{tab.label}</Tab>
      </TabList>
      <div>
        <TabPanel tabId={tab.id} key={tab.id} active={tab.active}>tabPanel1</TabPanel>
      </div>
    </Wrapper>);

    let tab1 = wrapper.find(`#${tab.id}`);
    let hostNode = tab1.hostNodes().at(0);


    hostNode.simulate('focus');
    wrapper.update();


    expect(toJson(wrapper)).toMatchSnapshot()
  });

  describe('prevents going to next if next isnt enabled', () => {
    let state: EasyTabComponentState;
    let wrapper: ReactWrapper;

    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label});
      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label});


      wrapper = mountForMobx({state: state}, (props) => {
        return <Wrapper manager={props.state}>
          <TabList>
            {
              props.state.panels.map((tab:any) => {
                return <Tab id={tab.id} key={tab.id} className={tab.enabled ? 'enabled' : undefined}
                            active={tab.active}>{tab.label}</Tab>
              })
            }
          </TabList>
          <div>
            {
              props.state.panels.map((tab:any) => {
                return <TabPanel tabId={tab.id} key={tab.id} active={tab.active}>
                  <button onClick={props.state.moveToNextTab}/>
                </TabPanel>
              })
            }
          </div>
        </Wrapper>
      });

      state.wrapperForFocus = wrapper

    });


    it('ignores if focused', () => {
      let secondTab = wrapper.find(Tab).at(1);
      secondTab.simulate('focus');
      wrapper.update();
      expect(toJson(wrapper)).toMatchSnapshot()
    });

    it('ignores from next button', () => {
      let button = wrapper.find('button').at(0);
      button.simulate('click');
      wrapper.update();
      expect(toJson(wrapper)).toMatchSnapshot()
    });

    it('ignores from backend move attempt', () => {

      state.moveToTab(state.tabsByName[data.tab2.tabName].id);
      wrapper.update();
      expect(toJson(wrapper)).toMatchSnapshot()
    })
  });

  describe('go to next and back', () => {
    let wrapper: ReactWrapper;
    let state: EasyTabComponentState;
    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label});
      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label});
      state.addTab({tabName: data.tab3.tabName, label: data.tab3.label});

      let tab1 = state.tabsByName[data.tab1.tabName];
      tab1.setEnabled(true);
      let tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      tab2.setEnabled(true);
      let tab3 = state.tabsByName[data.tab3.tabName];
      tab3.setEnabled(true);


      wrapper = mountForMobx({state: state}, (props) => {

        return <Wrapper manager={props.state}>
          <TabList>
            {
              props.state.panels.map((tab:any) => {
                return <Tab id={tab.id} key={tab.id} className={tab.enabled ? 'enabled' : undefined}
                            active={tab.active}>{tab.label}</Tab>
              })
            }
          </TabList>
          <div>
            {
              props.state.panels.map((tab:any) => {
                return <TabPanel tabId={tab.id} key={tab.id} active={tab.active}>
                  <button onClick={props.state.moveToNextTab}/>
                </TabPanel>
              })
            }
          </div>
        </Wrapper>

      });

      state.wrapperForFocus = wrapper
    });


    describe('go to next', () => {
      let commonCondition: (done: Function) => any;

      beforeEach(() => {
        commonCondition = (done: Function) => {

          runTestsOnConditions(new TriggerAndAction(
            () =>state.activeTab.tabName == data.tab2.tabName,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();
              expect(toJson(wrapper)).toMatchSnapshot();
              done()
            }
          ))
        };
      });


      it('go to next via click', (done) => {
        commonCondition(done);
        let secondTab = wrapper.find('#tab2');

        secondTab.hostNodes().simulate('focus');
        
      });

      it('go to next via next button', (done) => {
        commonCondition(done);
        let button = wrapper.find('button').at(0);
        button.hostNodes().simulate('click');
        
      });

      it('go to next via backend', (done) => {
        commonCondition(done);
        state.moveToTab(state.tabsByName[data.tab2.tabName].id);
        
      })
    });

    describe('go to next twice', () => {
      let commonCondition: (done: Function) => any;

      beforeEach(() => {
        commonCondition = (done: Function) => {

          runTestsOnConditions(new TriggerAndAction(
            () =>state.activeTab.tabName == data.tab3.tabName,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();
              expect(toJson(wrapper)).toMatchSnapshot();
              done()
            }
          ))
        };

      });

      it('go to next via click', (done) => {
        commonCondition(done);
        let secondTab = wrapper.find(Tab).at(1);
        secondTab.simulate('focus');
        wrapper.update();
        let thirdTab = wrapper.find(Tab).at(2);
        thirdTab.simulate('focus');
      });

      it('go to next via next button', (done) => {
        commonCondition(done);
        let button = wrapper.find('button').at(0);
        button.prop('onClick')(null);

        button = wrapper.find('button').at(1);
        button.prop('onClick')(null);

       

      });

      it('go to next via backend', (done) => {
        commonCondition(done);
        state.moveToNextTab();
        state.moveToNextTab();
       
      })
    });

    describe('go next twice, then back once', () => {

      let commonCondition: (done: Function) => void;
      beforeEach(() => {
        commonCondition = (done: Function) => {

          runTestsOnConditions(new TriggerAndAction(
            () =>state.activeTab.tabName == data.tab3.tabName,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();
            }
          ),
          new TriggerAndAction(
            () => state.activeTab.tabName == data.tab2.tabName,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();
              expect(toJson(wrapper)).toMatchSnapshot();
              done()
            }
          ))
        };
      });

      it('go via tab presses', (done) => {

        commonCondition(done);
        let secondTab = wrapper.find(Tab).at(1);
        secondTab.simulate('focus');

        let thirdTab = wrapper.find(Tab).at(2);
        thirdTab.simulate('focus');


        secondTab.simulate('focus')
      });

      it('go via next button presses', (done) => {
        commonCondition(done);
        let button = wrapper.find('button').at(0);
        button.prop('onClick')(null);

        button = wrapper.find('button').at(1);
        button.prop('onClick')(null);
        let secondTab = wrapper.find(Tab).at(1);
        secondTab.simulate('focus')

      });

      it('go via backend', (done) => {
        commonCondition(done);
        state.moveToNextTab();
        state.moveToNextTab();
        state.moveToPreviousTab()

      })
    })
  });


  describe('handle enabled properly', () => {

    let wrapper: ReactWrapper;
    let state: EasyTabComponentState;
    let tab3: MockableTabPanelState;
    let tab2: MockableTabPanelState;
    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label});
      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label});
      state.addTab({tabName: data.tab3.tabName, label: data.tab3.label});

      let tab1 = state.tabsByName[data.tab1.tabName];
      tab1.setEnabled(true);
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      tab2.setEnabled(true);
      tab3 = state.tabsByName[data.tab3.tabName];
      tab3.setEnabled(true);


      wrapper = mountForMobx({state: state}, (props) => {

        return <Wrapper manager={props.state}>
          <TabList>
            {
              props.state.panels.map((tab:any) => {
                return <Tab id={tab.id} key={tab.id} className={tab.enabled ? 'enabled' : undefined}
                            active={tab.active}>{tab.label}</Tab>
              })
            }
          </TabList>
          <div>
            {
              props.state.panels.map((tab:any) => {
                return <TabPanel tabId={tab.id} key={tab.id} active={tab.active}>
                  <button onClick={props.state.moveToNextTab}/>
                </TabPanel>
              })
            }
          </div>
        </Wrapper>

      });

      state.wrapperForFocus = wrapper
    });

    it('move back to previous tab if the current one is disabled', (done) => {

        runTestsOnConditions(new TriggerAndAction(
          () =>state.activeTab.tabName == data.tab3.tabName,
          () => {
            wrapper.instance().forceUpdate();
            wrapper.update();
          }
          ),
          new TriggerAndAction(
            () => state.activeTab.tabName == data.tab2.tabName,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();


            }
          ),
          new TriggerAndAction(
            () => tab3.enabled,
            () => {
              wrapper.instance().forceUpdate();
              wrapper.update();

              expect(toJson(wrapper)).toMatchSnapshot();
              done()
            }
          ));

      tab3.setEnabled(true);
      tab2.setEnabled(true);
      state.moveToTab(tab3);
      tab3.setEnabled(false);




    });

    it('move back to first tab if all but that one is disabled', (done) => {
      runTestsOnConditions(new TriggerAndAction(
        () =>state.activeTab.tabName == data.tab3.tabName,
        () => {
          wrapper.instance().forceUpdate();
          wrapper.update();
        }
        ),
        new TriggerAndAction(
          () => state.activeTab.tabName == data.tab1.tabName,
          () => {
            wrapper.instance().forceUpdate();
            wrapper.update();


          }
        ),
        new TriggerAndAction(
          () => tab2.enabled,
          () => {
            wrapper.instance().forceUpdate();
            wrapper.update();

            expect(toJson(wrapper)).toMatchSnapshot();
            done();
          }
        ));

      state.moveToTab(tab3);

      expect(tab3.active).toBe(true);

      tab2.setEnabled(false);
      tab3.setEnabled(false);
      state.moveToNextTab();

      tab2.setEnabled(true);


    })

  });

});

