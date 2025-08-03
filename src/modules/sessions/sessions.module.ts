import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Session, Message } from '../../database/entities';
import { SessionsController } from './sessions.controller';
import { SessionsService } from './sessions.service';
import { MessagesService } from '../messages/messages.service';

@Module({
  imports: [TypeOrmModule.forFeature([Session, Message])],
  controllers: [SessionsController],
  providers: [SessionsService, MessagesService],
  exports: [SessionsService],
})
export class SessionsModule {} 