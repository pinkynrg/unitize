require "spec_helper"

RSpec.describe Unitize::MeasurementUnit, type: :model do
  
  it "is valid with valid attributes" do
    expect(FactoryGirl.build(:measurement_unit)).to be_valid
  end

	it "is not valid without a name" do
    expect(FactoryGirl.build(:measurement_unit, name: nil)).not_to be_valid
  end  

  # it "is not valid with an already taken name" do
  #   measurement_unit_1 = FactoryGirl.create(:measurement_unit, name: "mu1")
  #   measurement_unit_2 = FactoryGirl.build(:measurement_unit, name: "mu1")
  #   expect(measurement_unit_2).not_to be_valid
  # end

  it "is not valid without a code" do
    expect(FactoryGirl.build(:measurement_unit, code: nil)).not_to be_valid
  end

  it "is not valid with an already taken code" do
    measurement_unit_1 = FactoryGirl.create(:measurement_unit, code: "mu1")
    measurement_unit_2 = FactoryGirl.build(:measurement_unit, code: "mu1")
    expect(measurement_unit_2).not_to be_valid
  end

  it "is not valid if the code can be already resolved by unitize engine" do
    FactoryGirl.create(:measurement_unit, code: "a")
    expect(FactoryGirl.build(:measurement_unit, code: "a2")).not_to be_valid
    FactoryGirl.create(:measurement_unit, code: "b")
    expect(FactoryGirl.build(:measurement_unit, code: "2b")).not_to be_valid
    FactoryGirl.create(:measurement_unit, code: "c")
    expect(FactoryGirl.build(:measurement_unit, code: "c.c")).not_to be_valid
    FactoryGirl.create(:measurement_unit, code: "d")
    expect(FactoryGirl.build(:measurement_unit, code: "d/d")).not_to be_valid
    
    expect(FactoryGirl.build(:measurement_unit, code: "e")).to be_valid
  end

  it "is not valid without a measurement type" do
    expect(FactoryGirl.build(:measurement_unit, measurement_type: nil)).not_to be_valid
  end

  it "is not valid without a scale unit code if derived unit" do
    expect(FactoryGirl.build(:measurement_unit, dim: nil, scale_unit_code: nil)).not_to be_valid
  end

  it "is not valid if unitize engine cannot resolve the scale unit code" do
    FactoryGirl.create(:measurement_unit, dim: "test", code: "test")
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_unit_code: "not_valid_code")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_unit_code: "test3")).to be_valid
  end

  it "is not valid if derived unit and scale_value is not present" do
    expect(FactoryGirl.build(:measurement_unit, dim: "test", scale_value: nil)).to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: nil)).not_to be_valid
  end

  it "is not valid if derived unit and scale_value is not positive numeric" do
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: "-100")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: "ciao")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: "0")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: "1")).to be_valid
    expect(FactoryGirl.build(:measurement_unit, :derived, scale_value: "123")).to be_valid
  end

  it "is not valid if scale function from validation cannot be evaluated by Dentaku" do
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "y + 1", scale_function_to: "x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "2x", scale_function_to: "x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x2", scale_function_to: "x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x.2", scale_function_to: "x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x**2", scale_function_to: "x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x + 1", scale_function_to: "x - 1")).to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "2*x", scale_function_to: "x/2")).to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "pow(x,2)", scale_function_to: "sqrt(x)")).to be_valid
  end

  it "is not valid if scale function from validation cannot be evaluated by Dentaku" do
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x", scale_function_to: "y - 1")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x", scale_function_to: "2x")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x", scale_function_to: "x2")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x", scale_function_to: "x.2")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x", scale_function_to: "x**2")).not_to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "x + 1", scale_function_to: "x - 1")).to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "2*x", scale_function_to: "x/2")).to be_valid
    expect(FactoryGirl.build(:measurement_unit, scale_function_from: "pow(x,2)", scale_function_to: "sqrt(x)")).to be_valid
  end

  it "is valid if I create new unit it is correctly added to memory and it works as expected" do
    # create base unit
    FactoryGirl.create(:measurement_unit, code: "m", dim: "M")
    expect(Unitize(1, "m").class).to be == Unitize::Measurement
    expect(Unitize(1, "m") + Unitize(1,"m")).to be == Unitize(2,"m")
    expect(Unitize(1, "m") - Unitize(1,"m")).to be == Unitize(0,"m")
    expect(Unitize(1, "m") * Unitize(1,"m")).to be == Unitize(1,"m2")
    expect(Unitize(1, "m") / Unitize(1,"m")).to be == Unitize(1,"1")

    # create derived unit
    FactoryGirl.create(:measurement_unit, code: "squared_m", scale_value: 1, scale_unit_code: "m2")
    expect(Unitize(1, "squared_m").class).to be == Unitize::Measurement
    expect(Unitize(1, "squared_m") + Unitize(1,"squared_m")).to be == Unitize(2,"m.m")
    expect(Unitize(1, "squared_m") - Unitize(1,"squared_m")).to be == Unitize(0,"m2")
    expect(Unitize(1, "squared_m") * Unitize(1,"squared_m")).to be == Unitize(1,"squared_m2")
    expect(Unitize(1, "squared_m") / Unitize(1,"squared_m")).to be == Unitize(1,"1")

    # create special unit
    FactoryGirl.create(:measurement_unit, code: "special_squared_m", scale_value: 1, scale_unit_code: "squared_m", special: true, scale_function_from: "pow(x,3)", scale_function_to: "pow(x,1/3)")
    expect(Unitize(1, "special_squared_m").class).to be == Unitize::Measurement
    expect(Unitize(1, "special_squared_m") + Unitize(1,"special_squared_m")).to be == Unitize(2**3,"m.m")
    expect(Unitize(1, "special_squared_m") - Unitize(3,"special_squared_m")).to be == Unitize(-2**3,"m.m")
    # expect(Unitize(1, "special_squared_m") * Unitize(3,"special_squared_m")).to be == Unitize(1**3,"squared_m") * Unitize(3**3,"squared_m")
    expect(Unitize(1, "special_squared_m") / Unitize(1,"special_squared_m")).to be == Unitize(1,"1")
  end

  it "is valid if I edit new unit it is correctly edited to memory" do
    some_base_1 = FactoryGirl.create(:measurement_unit, name: "base_1", code: "base_1_code", dim: "dim_1_code")
    some_base_2 = FactoryGirl.create(:measurement_unit, name: "base_2", code: "base_2_code", dim: "dim_2_code")
    some_type_1 = FactoryGirl.create(:measurement_type)
    some_type_2 = FactoryGirl.create(:measurement_type)

    unit = FactoryGirl.create(:measurement_unit, :derived, measurement_type: some_type_1, name: "name_v1", code: "v1", scale_value: "1", symbol: "v1!", scale_unit_code: some_base_1.code)

    # basic unit
    expect(Unitize(1, "v1").class).to be == Unitize::Measurement
    expect(Unitize::Atom.find("v1").name).to be == "name_v1"
    expect(Unitize::Atom.find("v1").property).to be == some_type_1.name
    expect(Unitize::Atom.find("v1").code).to be == "v1"
    expect(Unitize::Atom.find("v1").scale.value).to be == 1
    expect(Unitize::Atom.find("v1").scale.unit.expression).to be == some_base_1.code
    expect(Unitize::Atom.find("v1").metric).to be == true
    expect(Unitize::Atom.find("v1").special).to be  == false
    expect(Unitize::Atom.find("v1").arbitrary).to be == false
    expect(Unitize::Atom.find("v1").symbol).to be == "v1!"

    Unitize::MeasurementUnit.find_by(code: "v1").update({
      code: "v2", 
      name: "name_v2", 
      measurement_type: some_type_2,
      scale_value: 3,
      scale_unit_code: some_base_2.code,
      symbol: "v2!"
    })

    expect { Unitize(1, "v1") }.to raise_error(Unitize::ExpressionError)
    expect(Unitize(1, "v2").class).to be == Unitize::Measurement
    expect(Unitize::Atom.find("v2").name).to be == "name_v2"
    expect(Unitize::Atom.find("v2").property).to be == some_type_2.name
    expect(Unitize::Atom.find("v2").code).to be == "v2"
    expect(Unitize::Atom.find("v2").scale.value).to be == 3
    expect(Unitize::Atom.find("v2").scale.unit.expression).to be == some_base_2.code
    expect(Unitize::Atom.find("v2").metric).to be == true
    expect(Unitize::Atom.find("v2").special).to be == false
    expect(Unitize::Atom.find("v2").arbitrary).to be == false
    expect(Unitize::Atom.find("v2").symbol).to be == "v2!"

    Unitize::MeasurementUnit.find_by(code: "v2").update({
      code: "v3", 
      name: "name_v3", 
      scale_value: 1,
      metric: false,
      special: true,
      scale_function_from: "pow(x,2)",
      scale_function_to: "sqrt(x)",
      symbol: "v3!"
    })

    expect { Unitize(1, "v2") }.to raise_error(Unitize::ExpressionError)
    expect(Unitize(1, "v3").class).to be == Unitize::Measurement
    expect(Unitize::Atom.find("v3").name).to be == "name_v3"
    expect(Unitize::Atom.find("v3").property).to be == some_type_2.name
    expect(Unitize::Atom.find("v3").code).to be == "v3"
    expect(Unitize::Atom.find("v3").scale.value).to be == 1
    expect(Unitize::Atom.find("v3").scale.unit.expression).to be == some_base_2.code
    expect(Unitize::Atom.find("v3").scale.function_from).to be  == "pow(x,2)"
    expect(Unitize::Atom.find("v3").scale.function_to).to be  == "sqrt(x)"
    expect(Unitize::Atom.find("v3").metric).to be == false
    expect(Unitize::Atom.find("v3").special).to be  == true
    expect(Unitize::Atom.find("v3").arbitrary).to be == false
    expect(Unitize::Atom.find("v3").symbol).to be == "v3!"

  end

  it "is valid if I hard delete new unit it is correctly deleted from memory" do

    another_base_code = FactoryGirl.create(:measurement_unit, name: "base_1", code: "another_base_code", dim: "dim_1_code")
    some_special_unit = FactoryGirl.create(:measurement_unit, code: "another_special_unit", scale_value: 1, scale_unit_code: another_base_code.code, special: true, scale_function_from: "pow(x,3)", scale_function_to: "pow(x,1/3)")
    expect(Unitize(1, "another_special_unit").class).to be == Unitize::Measurement
    Unitize::MeasurementUnit.find_by(code: "another_special_unit").destroy
    expect { Unitize(1, "another_special_unit") }.to raise_error(Unitize::ExpressionError)

  end

  it "raises error if i try to access unit that doesn't exists" do
    expect { Unitize(1, "some_non_existing_unit") }.to raise_error(Unitize::ExpressionError)
  end

end