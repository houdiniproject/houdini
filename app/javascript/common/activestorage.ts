// License: LGPL-3.0-or-later
import { DirectUpload, Blob } from '@rails/activestorage';

export function uploadFile(controllerUrl: string, file: File): Promise<Blob> {

	const duPromise = new Promise<Blob>((resolve, reject) => {
		// eslint-disable-next-line @typescript-eslint/no-empty-function
		const du = new DirectUpload(file, controllerUrl);

		du.create((error, result) => {
			if (error) { reject(error); }
			if (result) { resolve(result); }
		});
	});
	return duPromise;
}