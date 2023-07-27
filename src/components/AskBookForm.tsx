import React, { useState } from "react";
import { Button, Col, Input, Row } from 'reactstrap';

const AskBookForm: React.FC = () => {

  return (
    <form>
      <Row>
        <Input type="textarea" />
      </Row>
      <Row className="mt-3">
        <Col>
          <Button className="mx-1">Ask Question</Button>
          <Button>I'm Feeling Lucky</Button>
        </Col>
      </Row>
    </form>
  );
};

export default AskBookForm;
