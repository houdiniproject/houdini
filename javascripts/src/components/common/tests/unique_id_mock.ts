// Under Lodash license (MIT/ISC) - https://raw.githubusercontent.com/lodash/lodash/4.17.10-npm/LICENSE
import * as _ from 'lodash'

export class UniqueIdMock {
  idCounter:number=0

  public uniqueId(prefix:string):string {
    var id = ++this.idCounter;
    return _.toString(prefix) + id;
  }

  public reset(){
    this.idCounter = 0
  }

}