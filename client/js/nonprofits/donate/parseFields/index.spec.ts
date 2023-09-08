import { splitParam } from "."


describe('.splitParam', () => {
  it('splits on _ and , and ;', () => {
    expect(splitParam("Another,place.that should; be --- _ split")).toHaveLength(4);
  })
})