export default function ReturnLocation(input:string) : 'dashboard'|'payouts' {
    switch(input){
        case 'dashboard':
        case 'payouts':
            return input
        default:
            return 'dashboard'
    }
}