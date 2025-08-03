import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiSecurity, ApiBody, ApiProperty } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { IsString } from 'class-validator';

import { RagService } from './rag.service';

// Define DTOs inline to avoid TypeScript 5.9.2 decorator issues
export class RagChatDto {
  @ApiProperty({
    example: 'What is artificial intelligence?',
    description: 'Message to send to RAG system'
  })
  @IsString()
  message: string;
}

export class RagQueryDto {
  @ApiProperty({
    example: 'machine learning algorithms',
    description: 'Query to search documents'
  })
  @IsString()
  query: string;
}

@ApiTags('RAG')
@Controller('rag')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiSecurity('api-key')
export class RagController {
  constructor(private readonly ragService: RagService) {}

  @Post('chat')
  @ApiOperation({ summary: 'Chat with RAG system' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          example: 'What is artificial intelligence?',
          description: 'Message to send to RAG system'
        }
      },
      required: ['message']
    }
  })
  @ApiResponse({ status: 200, description: 'RAG response generated' })
  async chatWithDocuments(@Body() body: RagChatDto) {
    return this.ragService.chatWithDocuments(body.message);
  }

  @Post('query')
  @ApiOperation({ summary: 'Query documents with RAG' })
  @ApiBody({ type: RagQueryDto })
  @ApiResponse({ status: 200, description: 'Query response generated' })
  async query(@Body() body: RagQueryDto) {
    return this.ragService.queryDocuments(body.query);
  }
} 