/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const React = require('react');

const CompLibrary = require('../../core/CompLibrary.js');
const Container = CompLibrary.Container;
const GridBlock = CompLibrary.GridBlock;

const siteConfig = require(process.cwd() + '/siteConfig.js');

class Help extends React.Component {
  render() {
    const supportLinks = [
      {
        content:
          'Learn more using the [documentation on this site.](/test-site/docs/en/doc1.html)',
        title: 'Browse Docs',
      },
      {
        content: 'Ask questions about the documentation and project <br/><a href="http://xcodeswift.herokuapp.com/">Join group</a>',
        title: 'Join Slack',
      },
      {
        content: "Find out what's new with this project following <a href='https://twitter.com/xcodeswiftio'>@xcode.swift</a> on Twitter.",
        title: 'Stay up to date',
      },
    ];

    return (
      <div className="docMainWrapper wrapper">
        <Container className="mainContainer documentContainer postContainer">
          <div className="post">
            <header className="postHeader">
              <h2>Need help?</h2>
            </header>
            <p>If you need help with Sake we recommend you to check out the links below:</p>
            <GridBlock contents={supportLinks} layout="threeColumn" />
          </div>
          <div className="post">
            <header className="postHeader">
              <h2>xcode.swift</h2>
            </header>
            <p>This project is maintained by a non-profit and open source organization <a href='https://github.com/xcodeswift'>xcode.swift</a>. At xcode.swift we aim to build tools written in Swift to facilitate and automate working tasks in Xcode projects.</p>
            <p>
            Xcode.swift is an inclusive organziation where anyone is welcome and encouraged to contribute. All the tools are the result of many people's work and thus, they are published and maintain as part of an organization of which everyone is part.
            </p>
          </div>
        </Container>
      </div>
    );
  }
}

module.exports = Help;
