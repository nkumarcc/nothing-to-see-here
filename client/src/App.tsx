import React from 'react';
import './App.scss';
import AskBookForm from './components/AskBookForm';
import { Col, Container, Row } from 'reactstrap';

function App() {
  return (
    <Container className="App mt-5">
      <Row>
        <Col>
          <img src={process.env.PUBLIC_URL + '/book.png'} alt="Book" />
        </Col>
      </Row>
      <h1>Ask My Book</h1>
      <p>This is my product engineering challenge to prove that I am indeed worthy.</p>
      <AskBookForm />
    </Container>

  );
}

export default App;
