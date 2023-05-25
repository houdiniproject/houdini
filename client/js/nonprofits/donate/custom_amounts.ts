// License: LGPL-3.0-or-later
const defaultAmounts = [10,25,50,100,250,500,1000];

/**
 * A function to allow us to get the default amounts
 * 
 * Theoretically, this might not be hardcoded in the future so let's not assume it is.
 * @returns the default amounts
 */
export function getDefaultAmounts(): number[] {
  return defaultAmounts;
}