import * as React from 'react'
import 'jest';
import CurrencyInput from './index'
import * as ReactDOM from 'react-dom';
import * as ReactTestUtils from 'react-dom/test-utils';
//import setup from './setup'



// describe('react-currency-input', function(){

//     before('setup dom', function(){
//         setup(); // setup the jsdom
//     });

//     describe('default arguments', function(){

//         before('render and locate element', function() {
//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput />
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         it('<CurrencyInput> should have masked value of "0.00"', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00')
//         });


//         it('<input> should be of type "text"', function() {
//             expect(this.inputComponent.getAttribute('type')).toBe('text')
//         });

//         it('does not auto-focus by default', function() {
//             expect(this.renderedComponent.props.autoFocus).to.be.false
//         });
//     });

//     describe('custom arguments', function(){

//         before('render and locate element', function() {
//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput
//                   decimalSeparator=","
//                   thousandSeparator="."
//                   precision="3"
//                   value="123456789"
//                   inputType="tel"
//                   id="currencyInput"
//                   autoFocus={true} />
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         it('<CurrencyInput> should have masked value of "123.456,789"', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('123.456.789,000')
//         });

//         it('<input> should be of type "tel"', function() {
//             expect(this.inputComponent.getAttribute('type')).toBe('tel')
//         });

//         it('should be auto focused', function() {
//           var focusedElement = document.activeElement;
//           expect(focusedElement.getAttribute('id')).toBe("currencyInput");
//         });
//     });


//     describe('properly convert number value props into display values', function(){

//         it('adds decimals to whole numbers to match precision', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value={123456789} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('123,456,789.00')
//         });

//         it('Does not change value when precision matches', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value={1234567.89} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.89')
//         });


//         it('Rounds down properly when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value={1234567.89123} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.89')
//         });


//         it('Rounds up properly when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value={1234567.89999} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.90')
//         });

//         it('Rounds up the whole number when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="0" value={1234567.89999} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,568')
//         });

//         it('it handles initial value as the integer 0,', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value={0} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('0.00')
//         });

//         it('it handles initial value as the float 0.00,', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value={0.00} />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('0.00')
//         });

//     });


//     describe('properly convert string value props into display values', function(){

//         it('adds decimals to whole numbers to match precision', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value="6300" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('6,300.00')
//         });


//         it('Does not change value when precision matches', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value="1234567.89" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.89')
//         });


//         it('Rounds down properly when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value="1234567.89123" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.89')
//         });


//         it('Rounds up properly when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="2" value="1234567.89999" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.90')
//         });


//         it('Rounds up the whole number when an number with extra decimals is passed in', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput precision="0" value="1234567.89999" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,568')
//         });


//         it('Handles strings with separators', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1,000.01" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,000.01')
//         });


//         it('Handles strings with prefixes', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="$10.01" prefix="$" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('$10.01')
//         });

//         it('Handles strings with suffixes', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="10.01 kr" suffix=" kr" />
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('10.01 kr')
//         });


//         it('Handles strings with custom separators', function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="123.456.789,12" decimalSeparator="," thousandSeparator="."/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('123.456.789,12')
//         });


//         it("Handles 1,234,567.89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1,234,567.89" decimalSeparator="." thousandSeparator=","/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567.89')
//         });


//         it("Handles 1 234 567.89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1,234,567.89" decimalSeparator="." thousandSeparator=" "/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1 234 567.89')
//         });

//         it("Handles 1 234 567,89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1 234 567,89" decimalSeparator="," thousandSeparator=" "/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1 234 567,89')
//         });

//         it("Handles 1,234,567·89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1,234,567·89" decimalSeparator="·" thousandSeparator=","/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1,234,567·89')
//         });

//         it("Handles 1.234.567,89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1.234.567,89" decimalSeparator="," thousandSeparator="."/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1.234.567,89')
//         });

//         it("Handles 1˙234˙567,89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1˙234˙567,89" decimalSeparator="," thousandSeparator="˙"/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe('1˙234˙567,89')
//         });


//         it("Handles 1'234'567.89 format", function() {
//             var renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput value="1'234'567.89" decimalSeparator="." thousandSeparator="'"/>
//             );
//             expect (renderedComponent.getMaskedValue()).toBe("1'234'567.89")
//         });



//     });

//     describe('change events', function(){

//         before('render and locate element', function() {
//             this.handleChange = sinon.spy();

//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput onChange={this.handleChange} value="0"/>
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         it('should call onChange', function() {
//             this.inputComponent.value=123456789;
//             ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.handleChange).to.have.been.calledWith("1,234,567.89", 1234567.89);
//         });


//         it('should change the masked value', function() {
//             this.inputComponent.value=123456789;
//             ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe("1,234,567.89");
//         });


//         it('should change the component value', function() {
//             this.inputComponent.value=123456789;
//             ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.inputComponent.value).toBe("1,234,567.89");
//         });


//     });


//     describe('negative numbers', function() {

//         before('render and locate element', function() {
//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput onChange={this.handleChange} value="0" allowNegative={true}/>
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         beforeEach('reset value to 0', function() {
//             this.inputComponent.value = "0";
//             ReactTestUtils.Simulate.change(this.inputComponent);
//         });

//         it('should render 0 without negative sign', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00');
//             this.inputComponent.value = "-0"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00');
//         });

//         it('should render number with no or even number of "-" as positive', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00');
//             this.inputComponent.value = "123456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "--123456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "123--456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "123456--"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "--123--456--"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "123456----"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//         });

//         it('should render number with odd number of "-" as negative', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00');
//             this.inputComponent.value = "-123456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//             this.inputComponent.value = "123-456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//             this.inputComponent.value = "123456-"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//             this.inputComponent.value = "-123-456-"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//         });

//         it('should correctly change between negative and positive numbers', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00');
//             this.inputComponent.value = "123456"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "1,234.56-"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//             this.inputComponent.value = "-1,234.56-"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//             this.inputComponent.value = "1-,234.56"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('-1,234.56');
//             this.inputComponent.value = "-1,234.-56"; ReactTestUtils.Simulate.change(this.inputComponent);
//             expect(this.renderedComponent.getMaskedValue()).toBe('1,234.56');
//         });

//     });


//     describe('currency prefix', function() {

//         before('render and locate element', function () {
//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput onChange={this.handleChange} value="0" prefix="$"/>
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         it('should render the prefix', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('$0.00');
//         });

//     });

//     describe('currency suffix', function() {

//         before('render and locate element', function () {
//             this.renderedComponent = ReactTestUtils.renderIntoDocument(
//                 <CurrencyInput onChange={this.handleChange} value="0" suffix=" kr"/>
//             );

//             this.inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 this.renderedComponent,
//                 'input'
//             );
//         });

//         it('should render the suffix', function() {
//             expect(this.renderedComponent.getMaskedValue()).toBe('0.00 kr');
//         });

//     });

//     describe('input selection', function() {
//         let defaultProps = {
//             allowNegative: true,
//             handleChange: () => {},
//             value: '0',
//             prefix: '$',
//             suffix: ' s'
//         };
//         let divElem;
//         let renderComponent = function(props = {}) {
//             divElem = document.createElement('div');
//             document.body.appendChild(divElem);

//             const componentProps = Object.assign({}, defaultProps, props);

//             const renderedComponent = ReactDOM.render(
//                 <CurrencyInput {...componentProps} />,
//                 divElem
//             );
//             const inputComponent = ReactTestUtils.findRenderedDOMComponentWithTag(
//                 renderedComponent,
//                 'input'
//             );

//             inputComponent.value = "0";
//             ReactTestUtils.Simulate.change(inputComponent);

//             return { renderedComponent, inputComponent };
//         };

//         after('clean up dom', function() {
//             document.body.removeChild(divElem);
//         });

//         it('sanity - renders "$0.00 s"', function() {
//             const { renderedComponent } = renderComponent();
//             expect(renderedComponent.getMaskedValue()).toBe('$0.00 s');
//         });

//         it('should consider precision absence', function() {
//             const { inputComponent } = renderComponent({ precision: 0 });

//             expect(inputComponent.selectionStart).toBe(2);
//             expect(inputComponent.selectionEnd).toBe(2);
//         });

//         xit('should highlight number on focus', function() {
//             const { inputComponent } = renderComponent();
//             ReactTestUtils.Simulate.focus(inputComponent);
//             expect(inputComponent.selectionStart).toBe(1);
//             expect(inputComponent.selectionEnd).toBe(5);
//         });

//         xit('should consider the negative sign when highlighting', function() {
//             const { inputComponent } = renderComponent();

//             inputComponent.value = '-4.35';
//             ReactTestUtils.Simulate.change(inputComponent);

//             ReactTestUtils.Simulate.focus(inputComponent);
//             expect(inputComponent.selectionStart).toBe(2);
//             expect(inputComponent.selectionEnd).toBe(6);
//         });

//         xit('should adjust start/end by 1 when entering a number', function() {
//             const { inputComponent } = renderComponent();

//             inputComponent.value = '134';
//             ReactTestUtils.Simulate.change(inputComponent);
//             ReactTestUtils.Simulate.focus(inputComponent);

//             inputComponent.setSelectionRange(1, 1);
//             inputComponent.value = '1234';
//             ReactTestUtils.Simulate.change(inputComponent);

//             expect(inputComponent.selectionStart).toBe(2);
//             expect(inputComponent.selectionEnd).toBe(2);
//         });

//     });

// });
