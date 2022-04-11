// License: LGPL-3.0-or-later
import * as React from "react";
import { render, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import AnimatedCheckmark from "./AnimatedCheckmark";
import { IntlProvider } from "../../intl";
import { convert } from 'dotize';
import I18n from '../../../i18n';

function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const translations = I18n.translations['en'] as any;
	return (<IntlProvider messages={convert(translations)} locale={'en'}>
		{props.children}
	</IntlProvider>);
}
describe('Animated Checkmark', () => {
	it('check if it renders', async () => {
		expect.hasAssertions();
		const {getByTestId} = render(<Wrapper><AnimatedCheckmark ariaLabel={"login.success"} role={"status"}></AnimatedCheckmark></Wrapper>);
		const checkmark = getByTestId("CheckmarkTest");
		await waitFor(() => {
			expect(checkmark).toBeInTheDocument();
		});
	});
	it('check Aria Label Message', async () => {
		expect.hasAssertions();
		const {queryByLabelText } = render(<Wrapper><AnimatedCheckmark ariaLabel={"You have successfully signed in."} role={"status"}></AnimatedCheckmark></Wrapper>);
		await waitFor(() => {
			expect(queryByLabelText("You have successfully signed in.")).toBeInTheDocument();
		});
	});
	it('role has status as value', async () => {
		expect.hasAssertions();
		const {getByTestId } = render(<Wrapper><AnimatedCheckmark ariaLabel={"login.success"} role={"status"}></AnimatedCheckmark></Wrapper>);
		const role = getByTestId("CheckmarkTest");
		await waitFor(() => {
			expect(role).toHaveAttribute('role', 'status');
		});
	});
});