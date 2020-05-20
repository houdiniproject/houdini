// License: LGPL-3.0-or-later
import 'jest';
import {Form} from "mobx-react-form"
import {WizardState, WizardTabPanelState} from "./wizard_state";
import {action, computed, observable} from 'mobx';

class MockableTabPanelState extends WizardTabPanelState {
  @observable
  customIsValid: boolean;

  @action.bound
  setValid(validity: boolean) {
    this.customIsValid = validity;
  }

  @computed
  get isValid(): boolean {
    return this.customIsValid
  }
}

class EasyWizardState extends WizardState<MockableTabPanelState> {
  constructor() {
    super(MockableTabPanelState)
  }

  createForm(i: any): Form {
    return new Form(i)
  }

  //we mock this because we want to skip the focus group code for these tests
  @action.bound
  focusTab(id:string) : void {
    this.activateTab(id)
  }

}

describe("WizardState", () => {
  let data =
    {
      tab1: {
        tabName: "Tab1",
        label: "Label1",
        subFormDef: {extra: "nothing"}
      },
      tab2: {
        tabName: "Tab2",
        label: "Label2",
        subFormDef: {extra: "not"}
      },
      tab3: {
        tabName: "Tab3",
        label: "Label3",
        subFormDef: {extra: "no3t"}
      },


    };

  it('adds tab properly', () => {
    let state = new EasyWizardState();


    state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});
    state.initialize();

    let tab = state.tabsByName[data.tab1.tabName];
    expect(tab.tabName).toBe(data.tab1.tabName);
    expect(tab.label).toBe(data.tab1.label);
    expect(tab.form.extra).toBe(data.tab1.subFormDef.extra);
    expect(tab.enabled).toBe(true);
    expect(tab.previous).toBe(null);
    expect(tab.next).toBe(null)
  });

  it('prevents going to next if next isnt enabled', () => {
    let state = new EasyWizardState();

    state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});
    state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
    state.initialize();

    expect(state.activeTab).toBe(state.tabsByName[data.tab1.tabName]);
    state.tabsByName[data.tab1.tabName].setValid(false);
    state.activateTab(state.tabsByName[data.tab2.tabName].id);
    expect(state.activeTab).toBe(state.tabsByName[data.tab1.tabName]);
    expect(state.tabsByName[data.tab2.tabName].active).toBeFalsy()
  });

  describe('go to next and back', () => {
    let state = new EasyWizardState();

    state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});
    state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
    state.addTab({tabName: data.tab3.tabName, label: data.tab3.label, tabFieldDefinition: data.tab3.subFormDef});
    state.initialize();

    let tab1 = state.tabsByName[data.tab1.tabName];
    tab1.setValid(true);
    let tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
    tab2.setValid(true);
    let tab3 = state.tabsByName[data.tab3.tabName];
    it('go to next', () => {
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

    let state: EasyWizardState = null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3: MockableTabPanelState = null;

    beforeEach(() => {
      state = new EasyWizardState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});
      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
      state.addTab({tabName: data.tab3.tabName, label: data.tab3.label, tabFieldDefinition: data.tab3.subFormDef});
      state.initialize();
      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState);
      tab1.setValid(true);
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      tab2.setValid(true);
      tab3 = (state.tabsByName[data.tab3.tabName]as MockableTabPanelState)
    });

    it('move back to previous tab if the current one is disabled', () => {

      state.activateTab(tab3);

      expect(tab3.active).toBe(true);
      expect(tab1.active).toBe(false);
      expect(tab2.active).toBe(false);
      tab2.setValid(false);

      expect(tab3.active).toBe(false);
      expect(tab2.active).toBe(true);
      expect(state.activeTab).toBe(tab2)
    });

    it('move back to first tab if all but that one is disabled', () => {
      state.activateTab(tab3);

      expect(tab3.active).toBe(true);

      tab2.setValid(false);
      tab1.setValid(false);

      expect(tab3.active).toBe(false);
      expect(tab2.active).toBe(false);
      expect(tab1.active).toBe(true);
      expect(state.activeTab).toBe(tab1);

      tab1.setValid(true);
      expect(state.activeTab).toBe(tab1);


      tab1.setValid(false);
      expect(state.activeTab).toBe(tab1);


      state.moveToNextTab();
      expect(state.activeTab).toBe(tab1);


      tab2.setValid(true);
      expect(state.activeTab).toBe(tab1)

    })

  });


  describe("before works properly", () => {
    let state: EasyWizardState = null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3: MockableTabPanelState = null;
    beforeEach(() => {
      state = new EasyWizardState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});

      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    });

    it("handles before when nothing else in it", () => {

      let tab2 = new MockableTabPanelState();
      state.initialize();
      expect(tab1.before(tab2)).toBeFalsy()
    });

    it("handles before before When nothing else in it", () => {

      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
      state.initialize();
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      expect(tab1.before(tab2)).toBeTruthy();
      expect(tab2.before(tab1)).toBeFalsy();
      tab3 = new MockableTabPanelState();

      expect(tab2.before(tab3)).toBeFalsy();
      expect(tab3.before(tab2)).toBeFalsy()
    })

  });

  describe("after works properly", () => {
    let state: EasyWizardState = null;
    let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3: MockableTabPanelState = null;
    beforeEach(() => {
      state = new EasyWizardState();
      state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});

      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    });

    it("handles before when nothing else in it", () => {

      let tab2 = new MockableTabPanelState();
      state.initialize();
      expect(tab1.after(tab2)).toBeFalsy();
      expect(tab2.after(tab1)).toBeFalsy()
    });

    it("handles before before When nothing else in it", () => {

      state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
      state.initialize();
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState);
      expect(tab2.after(tab1)).toBeTruthy();
      expect(tab1.after(tab2)).toBeFalsy();
      tab3 = new MockableTabPanelState();

      expect(tab2.before(tab3)).toBeFalsy();
      expect(tab3.before(tab2)).toBeFalsy()
    })

  })

});



