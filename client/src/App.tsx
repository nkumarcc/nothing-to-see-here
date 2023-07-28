import React from 'react';
import './App.css';
import AskBookForm from './components/AskBookForm';
import { Container } from 'reactstrap';

function App() {
  return (
    <Container className="App mt-5">
      <h1>Ask My Book</h1>
      <p>This is my product engineering challenge to prove that I am indeed worthy.</p>
      <AskBookForm />
    </Container>

  );
}

export default App;
