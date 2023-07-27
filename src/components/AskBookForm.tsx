import React, { useState } from "react";
import { Button, Col, Form, Input, Row } from 'reactstrap';

const AskBookForm: React.FC = () => {

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    console.log('form submitted with val: ', event.currentTarget.bookQuestion.value);
  }

  return (
    <Form onSubmit={handleSubmit}>
      <Row>
        <Input name="bookQuestion" type="textarea" />
      </Row>
      <Row className="mt-3">
        <Col>
          <Button type="submit" className="mx-1">Ask Question</Button>
          <Button type="button">I'm Feeling Lucky</Button>
        </Col>
      </Row>
    </Form>
  );
};

export default AskBookForm;
