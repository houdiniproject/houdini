// License: LGPL-3.0-or-later

export default function isSoldOut(g:{quantity?:number, total_gifts?:number}) : boolean {
	return !!(g.quantity && g.total_gifts && (g.quantity - g.total_gifts <= 0));
}