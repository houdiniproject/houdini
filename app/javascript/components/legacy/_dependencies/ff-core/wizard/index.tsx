/* eslint-disable react/prop-types */
import useSteps, { InputStepsState, KeyedStep, StepsObject } from '../../../../../hooks/useSteps';
import React, { createContext } from 'react';
import { noop } from 'lodash';

// from ff-core/wizard


interface WizardProps extends InputStepsState<KeyedStep & { body: JSX.Element, title: string }> {
	followup: () => JSX.Element;

}


export const WizardContext = createContext<StepsObject<{ body: JSX.Element, title: string }>>({} as unknown as StepsObject<{ body: JSX.Element, title: string }>);

export default function Wizard(props: WizardProps): JSX.Element {

	const {
		steps, followup,
	} = props;
	const stepManager = useSteps<{ body: JSX.Element, title: string }>({ steps, addStep: noop, removeStep: noop });

	const currentStep = stepManager.activeStep;



	const isCompleted = stepManager.activeStep === stepManager.steps.length - 1;
	return (
		<WizardContext.Provider value={stepManager}>
			<div className={'ff-wizard-body'}>
				<StepIndex
					currentStep={currentStep}
					isCompleted={isCompleted}
					stepNames={stepManager.steps.map(value => value.title)}
					jump={stepManager.goto}
				/>
				<Body currentStep={currentStep} isCompleted={isCompleted}>
					{stepManager.steps.map(i => i.body)}
				</Body>
				<Followup isCompleted={isCompleted}>
					{followup()}
				</Followup>;
			</div>
		</WizardContext.Provider>);
}


Wizard.defaultProps = {
	addStep: noop,
	removeStep: noop,
};




function Followup({ isCompleted, children }: React.PropsWithChildren<{ isCompleted: boolean }>) {
	return <div className="ff-wizard-followup" style={{
		display: isCompleted ? 'block' : 'none',
	}}>
		{children}
	</div>;
}

function StepIndex({ stepNames, isCompleted, currentStep, jump }: { stepNames: string[], isCompleted: boolean, currentStep: number, jump: (args: any) => void }) {
	const width = 100 / stepNames.length + '%';
	return <div className={'ff-wizard-index'}
		style={{ display: isCompleted ? 'none' : 'block' }}>
		{stepNames.map((name, idx) =>
			(<StepHeader
				width={width}
				name={name}
				currentStep={currentStep}
				idx={idx}
				jump={jump}
				key={name}
			/>)
		)}
	</div>;


}

function StepHeader({ width, jump, name, idx, currentStep }: { width: string, name: string, jump: (args: any) => void, idx: number, currentStep: number }) {
	const classNames = ['ff-wizard-index-label'];
	if (currentStep === idx) {
		classNames.push('ff-wizard-index-label--current');
	}
	if (currentStep > idx) {
		classNames.push('ff-wizard-index-label--accessible');
	}
	return (<span
		className={classNames.join(' ')}
		style={{ width: width }}
		onClick={() => jump(idx)} >
		{name}
	</span>);

}

function Body({ currentStep, isCompleted, children }: React.PropsWithChildren<{ currentStep: number, isCompleted: boolean }>) {
	return <div className={'ff-wizard-steps'} style={{
		display: isCompleted ? 'block' : 'none',
	}}>

		{React.Children.map(children, (child, idx) => (
			<StepBody idx={idx} currentStep={currentStep} key={idx}>
				{child}
			</StepBody> /* idx is a bad choice for key but we got not options */
		))}

	</div>;
}

function StepBody({ idx, currentStep, children }: React.PropsWithChildren<{ idx: number, currentStep: number }>) {
	return <div className={'ff-wizard-body-step'} style={{ display: currentStep === idx ? 'block' : 'none' }}>
		{children}
	</div>;
}