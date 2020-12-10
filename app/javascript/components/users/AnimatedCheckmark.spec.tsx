import * as React from "react";
import { fireEvent, render, waitFor } from "@testing-library/react";
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
	it('Check if it renders', async () => {
    const {getByTestId} = render(<Wrapper><AnimatedCheckmark ariaLabel={"ariaLabel"} role={"role"}></AnimatedCheckmark></Wrapper>)
    const checkmark = getByTestId("CheckmarkTest")
		await waitFor(() => {
			expect(checkmark).toBeInTheDocument()
		});
	});
});
// Make sure the correct values are being passed. In ariaLabel and role.