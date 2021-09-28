
import { UserSignInFailsOnceAndThenSucceeds, UserSignInWaitUntilSignal, UserSignInSucceeds, UserSignInSucceedsWithDelay, UserSignInFailsFromServerErrorWithDelay, UserSignInFailsFromInvalidLogin } from '../../api/mocks/users';
import { UserSignedInIfAuthenticated } from '../../api/api/mocks/users';

export const UserSignInFailsOnceAndThenSucceedsAndGetCurrentWaitsForAuthentication = [
	...UserSignInFailsOnceAndThenSucceeds,
	...UserSignedInIfAuthenticated,
];

export const UserWaitToSignInAndNotLoggedIn = [
	...UserSignInWaitUntilSignal,
	...UserSignedInIfAuthenticated,
];

export const UserSignsInOnFirstAttempt = [
	...UserSignInSucceeds,
	...UserSignedInIfAuthenticated,
];


export const UserSignsInOnFirstAttemptWith5SecondDelay = [
	...UserSignInSucceedsWithDelay,
	...UserSignedInIfAuthenticated,
];


export const UserSignInFailedWith500And5SecondDelay = [
	...UserSignInFailsFromServerErrorWithDelay,
	...UserSignedInIfAuthenticated,
];

export const UserSignInFailed = [
	...UserSignInFailsFromInvalidLogin,
];