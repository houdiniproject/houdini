// License: LGPL-3.0-or-later

// The old appl interface. Just doing so this is easier to migrate


interface Wizard {
	advance(stepName: string): void;
}



interface General {
		def(key: Record<string,unknown>): Appl;
		def(key: string, value: unknown): Appl;
		def_lazy(key:string, action:() => unknown):void;
}

interface Format {
	cents_to_dollars(cents:number):string;
	percentage(x:number, y:number):string;
	pluralize(num:number, noun:string):string;
	readable_date(date:string):string;
	readable_date_time(date:string):string;
	readable_date_time_to_iso(date:string):string;
}

interface Modal {
	close_modal():Appl;
	notify(msg:string):Appl;
	open_modal(modalId: string): Appl;
	open_modal_if_confirmed(modalId:string):Appl;
}

interface WithWizard {
	wizard:Wizard;
}

interface Redirect {
	redirect(url:string):void;
}

interface Loading {
	is_loading():void;
	not_loading():void;
}

interface Other {
	/**
	 * Unsure what this does
	 * @param prop a property string;
	 */
	vs(prop:string):unknown;
}



export type Appl = General & Format & Modal & WithWizard & Redirect & Loading & Other;


interface Payments {
	ajax_payment_details: {
		fetch: (id:number) => void;
	};

	payment_details: {
		data: {
			id: number;
		};
	};

	payments: {
		index():void;
	};


}

export type ApplWithPayments = Appl & Payments;

