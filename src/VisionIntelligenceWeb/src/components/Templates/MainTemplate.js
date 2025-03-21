import React from "react";
import Form from "../Organisms/Form";

const MainTemplate = () => {
  return (
    <div>
      <header>
        <h1>Welcome to Vision Intelligence</h1>
      </header>
      <main>
        <Form />
      </main>
      <footer>
        <p>&copy; 2023 Vision Intelligence</p>
      </footer>
    </div>
  );
};

export default MainTemplate;
