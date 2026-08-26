// A deliberately tiny contact form for the Hive eval fixture.
// The align case asks the Queen to "add an optional phone field" against this.

const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
];

function validate(values) {
  const errors = {};
  for (const field of FIELDS) {
    if (field.required && !values[field.name]) {
      errors[field.name] = `${field.label} is required`;
    }
  }
  if (values.email && !values.email.includes("@")) {
    errors.email = "Email looks invalid";
  }
  return errors;
}

module.exports = { FIELDS, validate };
