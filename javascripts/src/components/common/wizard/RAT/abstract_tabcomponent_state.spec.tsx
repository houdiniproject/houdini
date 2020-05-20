// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {observable, action, computed} from 'mobx'
import {AbstractTabComponentState, AbstractTabPanelState} from "./abstract_tabcomponent_state";

class MockableTabPanelState extends AbstractTabPanelState {
  @observable
  isEnabled:boolean;

  @action.bound
  setEnabled(enabled:boolean){
    this.isEnabled = enabled;
  }

  @computed
  get enabled():boolean {
    return this.isEnabled
  }

}

class EasyTabComponentState extends AbstractTabComponentState<MockableTabPanelState> {
  constructor() {
    super(MockableTabPanelState)
  }

  @action.bound
  addTab(tab:{ tabName: string, label: string }):MockableTabPanelState {
    const newTab = super.addTab(tab);
    if (this.panels.length == 1){
      newTab.setEnabled(true)
    }
    return newTab
  }

  //we mock this because we want to skip the focus group code for these tests
  @action.bound
  focusTab(id:string) : void {
    this.activateTab(id)
  }
}


describe('AbstractTabComponentState', () => {

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
  it('.createTab', () =>{
    let state = new EasyTabComponentState();


    state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});
    

    let tab = state.tabsByName[data.tab1.tabName];
    expect(tab.tabName).toBe(data.tab1.tabName);
    expect(tab.label).toBe(data.tab1.label);
    expect(tab.enabled).toBe(true);
    expect(tab.previous).toBe(null);
    expect(tab.next).toBe(null)
  });

  it('prevents going to next if next isnt enabled', () =>{
    let state = new EasyTabComponentState();

    state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});
    state.addTab({tabName:data.tab2.tabName, label:data.tab2.label});
    

    expect(state.activeTab).toBe(state.tabsByName[data.tab1.tabName]);
    state.moveToTab(state.tabsByName[data.tab2.tabName].id);
    expect(state.activeTab).toBe(state.tabsByName[data.tab1.tabName]);
    expect(state.tabsByName[data.tab2.tabName].active).toBeFalsy()
  });

  describe('go to next and back', () => {
    let state = new EasyTabComponentState();

    state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});
    state.addTab({tabName:data.tab2.tabName, label:data.tab2.label});
    state.addTab({tabName:data.tab3.tabName, label:data.tab3.label});
   
    let tab1 = state.tabsByName[data.tab1.tabName];
    tab1.setEnabled(true);
    let tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
    tab2.setEnabled(true);
    let tab3 = state.tabsByName[data.tab3.tabName];
    it('go to next', () =>{
      expect(state.nextTab).toBe(tab2);
      expect(state.previousTab).toBeNull();

      state.moveToNextTab();

      expect(state.activeTab).toBe(tab2);
  
      expect(state.previousTab).toBe(tab1);
      expect(state.nextTab).toBe(tab3);

      expect(tab1.active).toBeFalsy();
      expect(tab3.active).toBeFalsy()

    })
  });


  describe('handle moving back to tabs when one is disabled', () => {

    let state:EasyTabComponentState= null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3 : MockableTabPanelState = null;

    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});
      state.addTab({tabName:data.tab2.tabName, label:data.tab2.label});
      state.addTab({tabName:data.tab3.tabName, label:data.tab3.label});
      
      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState);
      tab1.setEnabled(true);
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      tab2.setEnabled(true);
      tab3 = (state.tabsByName[data.tab3.tabName]as MockableTabPanelState)
    });

    it ('move back to previous tab if the current one is disabled', () =>{

      tab3.setEnabled(true);
      tab2.setEnabled(true);
      state.moveToTab(tab3);

      expect(tab3.active).toBe(true);
     
      expect(tab1.active).toBe(false);
      expect(tab2.active).toBe(false);
      tab3.setEnabled(false);

      expect(tab3.active).toBe(false);
      expect(tab2.active).toBe(true);
      expect(state.activeTab).toBe(tab2)
      

    });

    it ('move back to first tab if all but that one is disabled', () =>{
      tab2.setEnabled(true);
      tab3.setEnabled(true);
      state.moveToTab(tab3);

      expect(tab3.active).toBe(true);

      tab2.setEnabled(false);
      tab3.setEnabled(false);


      expect(tab3.active).toBe(false);
      expect(tab2.active).toBe(false);
      expect(tab1.active).toBe(true);
      expect(state.activeTab).toBe(tab1);
      

      tab1.setEnabled(true);
      expect(state.activeTab).toBe(tab1);
      

      tab1.setEnabled(false);
      expect(state.activeTab).toBe(tab1);
      

      state.moveToNextTab();
      expect(state.activeTab).toBe(tab1);
      

      tab2.setEnabled(true);
      expect(state.activeTab).toBe(tab1)
     
    })

  });



  describe("before works properly", () =>{
    let state:EasyTabComponentState = null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3 : MockableTabPanelState = null;
    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});

      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    });

    it("handles before when nothing else in it",() =>{

      let tab2 = new MockableTabPanelState();
      
      expect(tab1.before(tab2)).toBeFalsy()
    });

    it("handles before before When nothing else in it",() =>{

      state.addTab({tabName:data.tab2.tabName, label:data.tab2.label})
      ;
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      expect(tab1.before(tab2)).toBeTruthy();
      expect(tab2.before(tab1)).toBeFalsy();
      tab3 = new MockableTabPanelState();

      expect(tab2.before(tab3)).toBeFalsy();
      expect(tab3.before(tab2)).toBeFalsy()
    })

  });

  describe("after works properly", () =>{
    let state:EasyTabComponentState = null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3 : MockableTabPanelState = null;
    beforeEach(() => {
      state = new EasyTabComponentState();
      state.addTab({tabName:data.tab1.tabName, label:data.tab1.label});

      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    });

    it("handles before when nothing else in it",() =>{

      let tab2 = new MockableTabPanelState();
      
      expect(tab1.after(tab2)).toBeFalsy();
      expect(tab2.after(tab1)).toBeFalsy()
    });

    it("handles before before When nothing else in it",() =>{

      state.addTab({tabName:data.tab2.tabName, label:data.tab2.label});
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      expect(tab2.after(tab1)).toBeTruthy();
      expect(tab1.after(tab2)).toBeFalsy();
      tab3 = new MockableTabPanelState();

      expect(tab2.before(tab3)).toBeFalsy();
      expect(tab3.before(tab2)).toBeFalsy()
    })

  })
    
});
