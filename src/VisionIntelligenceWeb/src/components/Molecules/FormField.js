import React from "react";
import Button from "../Atoms/Button";

const FormField = ({ label, type, onClick }) => {
  return (
    <div>
      <label>{label}</label>
      <input type={type} />
      <Button label="Submit" onClick={onClick} />
    </div>
  );
};

export default FormField;
