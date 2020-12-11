import * as React from "react";
import { getByTestId, render, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import AnimatedCheckmark from "./AnimatedCheckmark";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { HosterContext } from "../../hooks/useHoster";

function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const translations = I18n.translations['en'] as any;

	return <HosterContext.Provider value={{hoster: null}}>
		<IntlProvider messages={translations} locale={'en'}>
			<MockCurrentUserProvider>
				{props.children}
			</MockCurrentUserProvider>
		</IntlProvider>
	</HosterContext.Provider>;

}

describe('Animated Checkmark', () => {
	it('check if it renders', async () => {
		expect.hasAssertions();
		const {getByTestId} = render(<Wrapper><AnimatedCheckmark ariaLabel={"ariaLabel"} role={"role"}></AnimatedCheckmark></Wrapper>);
		const checkmark = getByTestId("CheckmarkTest");
		await waitFor(() => {
			expect(checkmark).toBeInTheDocument();
		});
	});

	it('check Aria Label Message', async () => {
		expect.hasAssertions();
		const {queryByLabelText } = render(<Wrapper><AnimatedCheckmark ariaLabel={"login.success"} role={"status"}></AnimatedCheckmark></Wrapper>);
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